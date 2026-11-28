//
//  CanvasService.swift
//  Sylly
//
//  Reads a student's Canvas calendar feed and turns it into a list of assignments.
//

import Foundation
import SwiftData

// MARK: - Canvas Service
// No server involved: the phone downloads the student's own feed link directly.
class CanvasService {

    // MARK: - Main Function: Fetch Assignments
    func fetchAssignments(from feedLink: String) async throws -> [CanvasItem] {

        // Step 1: Make sure the link is a real URL
        guard let url = URL(string: feedLink) else {
            throw CanvasError.invalidLink
        }

        // Step 2: Download the feed. A plain download, no POST like ClaudeService.
        let (data, response) = try await URLSession.shared.data(from: url)

        // Step 3: 200 means Canvas sent the feed. A wrong or reset link gives something else.
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw CanvasError.feedUnavailable
        }

        // Step 4: Turn the downloaded bytes into text
        guard let feedText = String(data: data, encoding: .utf8) else {
            throw CanvasError.unreadableFeed
        }

        // Step 5: Fix the wrapped lines, then sort them into one box per item
        let lines = unfoldLines(feedText)
        let events = readEvents(from: lines)

        // Step 6: Turn each box into a CanvasItem, skipping anything that isn't an assignment
        var items: [CanvasItem] = []
        for fields in events {
            if let item = makeItem(from: fields) {
                items.append(item)
            }
        }

        return items
    }

    // MARK: - Save Into Sylly
    // Puts Canvas assignments into their linked Sylly courses without making duplicates
    func saveItems(_ items: [CanvasItem], context: ModelContext) {

        // Step 1: Read every course once
        let request = FetchDescriptor<Course>()
        guard let courses = try? context.fetch(request) else { return }

        for item in items {
            // Step 2: Which Sylly course? Not linked yet → skip, the matching screen handles it
            guard let course = findCourse(for: item, in: courses) else { continue }

            // Step 3: Imported on an earlier refresh → keep the date current in case it moved
            if let existing = findExisting(for: item, in: course) {
                existing.dueDate = item.dueDate
                continue
            }

            // Step 4: Already scanned from the syllabus → link it instead of adding a copy
            if let twin = findTwin(for: item, in: course) {
                twin.canvasID = item.canvasID
                continue
            }

            // Step 5: New assignment, added the same way AddAssignmentSheet does it
            let newAssignment = Assignment(title: item.title, dueDate: item.dueDate, type: guessType(from: item.title))
            newAssignment.canvasID = item.canvasID
            newAssignment.course = course
            course.assignments.append(newAssignment)
        }

        // Step 6: Save, then rebuild reminders so new and moved assignments get the right ones
        do {
            try context.save()
            NotificationService.shared.refreshAll(context: context)
        } catch {
            print("Couldn't save Canvas assignments: \(error)")
        }
    }

    // MARK: - Group For The Matching Screen
    // One group per Canvas course that isn't linked to a Sylly course yet
    func groupByCourse(_ items: [CanvasItem], context: ModelContext) -> [CanvasCourseGroup] {

        // Step 1: Read every course once
        let request = FetchDescriptor<Course>()
        guard let courses = try? context.fetch(request) else { return [] }

        // Step 2: List each unlinked Canvas course once, e.g. ["course_111", "course_222"]
        var courseKeys: [String] = []
        for item in items {
            if findCourse(for: item, in: courses) != nil {
                continue        // already linked, saveItems handles it
            }
            if !courseKeys.contains(item.courseKey) {
                courseKeys.append(item.courseKey)
            }
        }

        // Step 3: For each course, collect its assignments into one group
        var groups: [CanvasCourseGroup] = []
        for key in courseKeys {
            var groupItems: [CanvasItem] = []
            for item in items {
                if item.courseKey == key {
                    groupItems.append(item)
                }
            }
            let suggestion = findSuggestion(for: groupItems, in: courses)
            groups.append(CanvasCourseGroup(courseKey: key, items: groupItems, suggestedCourse: suggestion))
        }

        return groups
    }

    // MARK: - Helpers

    // Long lines wrap onto the next line, which starts with a space. Glue them back together.
    private func unfoldLines(_ text: String) -> [String] {
        // Windows-style line endings become plain ones
        var cleaned = text.replacingOccurrences(of: "\r\n", with: "\n")
        // A line break followed by a space is a wrapped line, so remove both to glue it back
        cleaned = cleaned.replacingOccurrences(of: "\n ", with: "")
        return cleaned.components(separatedBy: "\n")
    }

    // Groups the lines into one dictionary per item, e.g. "DTSTART" → "20261029"
    private func readEvents(from lines: [String]) -> [[String: String]] {
        var events: [[String: String]] = []
        var current: [String: String] = [:]

        // BEGIN clears the box, END saves it, every other line goes in it
        for line in lines {
            if line == "BEGIN:VEVENT" {
                current = [:]
            } else if line == "END:VEVENT" {
                events.append(current)
            } else {
                // Split at the first ":" only, since URLs have their own colon
                let parts = line.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let nameWithSettings = parts[0]                                  // "DTSTART;VALUE=DATE"
                    let value = String(parts[1])                                     // "20261029"
                    let name = String(nameWithSettings.split(separator: ";")[0])     // "DTSTART"
                    current[name] = value
                }
            }
        }

        return events
    }

    // "Chapter 5 Homework  [xl_202720_EH]" → "Chapter 5 Homework"
    private func cleanTitle(_ summary: String) -> String {
        var title = summary

        // Cut off the course code in brackets at the end
        if let bracketStart = title.lastIndex(of: "[") {
            title = String(title[..<bracketStart])
        }

        // The feed writes commas as "\,"
        title = title.replacingOccurrences(of: "\\,", with: ",")

        return title.trimmingCharacters(in: .whitespaces)
    }

    // Reads "include_contexts=course_2566676" out of the link
    private func findCourseKey(in link: String) -> String? {
        guard let components = URLComponents(string: link) else { return nil }
        let pieces = components.queryItems ?? []

        for piece in pieces {
            if piece.name == "include_contexts" {
                return piece.value      // "course_2566676"
            }
        }

        return nil
    }

    // "20261029" → midnight Oct 29, which Sylly reads as "no time set"
    // "20261029T035900Z" → a real due time, written in universal time
    private func readDate(_ text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")   // reads the pattern exactly, whatever the phone's language

        if text.count == 8 {
            formatter.dateFormat = "yyyyMMdd"
            formatter.timeZone = .current
        } else {
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.timeZone = TimeZone(identifier: "UTC")
        }

        return formatter.date(from: text)
    }

    // Canvas doesn't say if something is an exam or homework, so guess from the title.
    // These names match the ones NotificationService uses for reminder timing.
    private func guessType(from title: String) -> String {
        let lowered = title.lowercased()

        // Checked first, so "Final Project" counts as a project and not an exam
        if lowered.contains("project") || lowered.contains("report") || lowered.contains("paper") || lowered.contains("essay") {
            return "project"
        }
        if lowered.contains("exam") || lowered.contains("midterm") || lowered.contains("final") {
            return "exam"
        }
        if lowered.contains("quiz") {
            return "quiz"
        }
        return "homework"
    }

    // The Sylly course linked to this item's Canvas course, or nil if it isn't linked yet
    private func findCourse(for item: CanvasItem, in courses: [Course]) -> Course? {
        for course in courses {
            if course.canvasCourseID == item.courseKey {
                return course
            }
        }
        return nil
    }

    // An assignment that came from this exact Canvas item on an earlier refresh
    private func findExisting(for item: CanvasItem, in course: Course) -> Assignment? {
        for assignment in course.assignments {
            if assignment.canvasID == item.canvasID {
                return assignment
            }
        }
        return nil
    }

    // A scanned assignment that's really the same one: no Canvas ID yet, due the same day,
    // and the titles match ("Quiz 2" and "Quiz 2 (Ch. 2-3)" count as a match)
    private func findTwin(for item: CanvasItem, in course: Course) -> Assignment? {
        let canvasTitle = item.title.lowercased()

        for assignment in course.assignments {
            // Already linked to a Canvas item, so it can't be this one's twin
            if assignment.canvasID != nil {
                continue
            }

            let sameDay = Calendar.current.isDate(assignment.dueDate, inSameDayAs: item.dueDate)
            let scannedTitle = assignment.title.lowercased()
            let titlesMatch = scannedTitle.contains(canvasTitle) || canvasTitle.contains(scannedTitle)

            if sameDay && titlesMatch {
                return assignment
            }
        }
        return nil
    }

    // The Sylly course that already has a scanned twin of one of these assignments
    private func findSuggestion(for items: [CanvasItem], in courses: [Course]) -> Course? {
        for course in courses {
            // Linked to a different Canvas course already
            if course.canvasCourseID != nil {
                continue
            }

            for item in items {
                if findTwin(for: item, in: course) != nil {
                    return course
                }
            }
        }
        return nil
    }

    // One box → one CanvasItem. nil means skip it.
    private func makeItem(from fields: [String: String]) -> CanvasItem? {
        let uid = fields["UID"] ?? ""

        // Only real assignments. This skips course evaluations and other calendar events.
        if !uid.hasPrefix("event-assignment-") {
            return nil
        }

        // Skip anything missing a piece rather than saving it half-broken
        guard let summary = fields["SUMMARY"] else { return nil }
        guard let dateText = fields["DTSTART"] else { return nil }
        guard let dueDate = readDate(dateText) else { return nil }
        guard let courseKey = findCourseKey(in: fields["URL"] ?? "") else { return nil }

        return CanvasItem(
            canvasID: uid,
            title: cleanTitle(summary),
            courseKey: courseKey,
            dueDate: dueDate
        )
    }
}

// MARK: - Data Models

// One assignment from the feed, before it gets saved into SwiftData
struct CanvasItem {
    let canvasID: String      // "event-assignment-20195700", goes into Assignment.canvasID
    let title: String
    let courseKey: String     // "course_2566676", groups items by course
    let dueDate: Date
}

// One Canvas course on the matching screen, with all its assignments
struct CanvasCourseGroup {
    let courseKey: String       // "course_2566731"
    let items: [CanvasItem]
    let suggestedCourse: Course?    // the picker starts here. nil = starts on Skip
}

enum CanvasError: Error, LocalizedError {
    case invalidLink
    case feedUnavailable
    case unreadableFeed

    var errorDescription: String? {
        switch self {
        case .invalidLink:
            return "That doesn't look like a Canvas calendar link."
        case .feedUnavailable:
            return "Couldn't reach Canvas. Check the link and your connection."
        case .unreadableFeed:
            return "Canvas sent something Sylly couldn't read."
        }
    }
}
