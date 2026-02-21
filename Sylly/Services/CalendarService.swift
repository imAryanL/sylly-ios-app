//
//  CalendarService.swift
//  Sylly
//
//  Handles exporting assignments to Apple Calendar using EventKit.
//  EventKit is Apple's framework for reading/writing calendar events.
//
//  Apple docs: https://developer.apple.com/documentation/eventkit
//  WWDC23 video: https://developer.apple.com/videos/play/wwdc2023/10052/
//

import Foundation
import EventKit

// MARK: - Calendar Service
// Singleton — only ONE instance exists in the whole app.
// Why? EKEventStore is expensive to create, Apple recommends making just one.
// Access anywhere with: CalendarService.shared
class CalendarService {

    // MARK: - Singleton
    static let shared = CalendarService()
    private init() {}

    // MARK: - Event Store
    // The gateway to the device's calendar database.
    // Like modelContext for SwiftData, but for Apple Calendar.
    private let store = EKEventStore()

    // MARK: - Check Authorization
    // Returns true if the app has calendar permission
    // iOS 17+ uses .fullAccess and .writeOnly instead of the old .authorized
    var isAuthorized: Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        return status == .fullAccess || status == .writeOnly
    }

    // MARK: - Request Permission
    // Shows the system "Can Sylly access your calendar?" dialog.
    // iOS only shows this ONCE — after that, user manages it in Settings.
    // Returns: true if granted, false if denied
    func requestAccess() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .notDetermined:
            // First time — show the permission popup
            return try await store.requestFullAccessToEvents()

        case .fullAccess, .writeOnly:
            // Already have permission (iOS 17+ terms)
            return true

        case .denied, .restricted:
            // User said no, or parental controls block it
            return false

        case .authorized:
            // Old iOS term (pre-17), kept for safety
            return true

        @unknown default:
            return false
        }
    }

    // MARK: - Export Assignments to Calendar
    // Creates one all-day calendar event per assignment.
    // @MainActor because SwiftData writes must happen on the main thread.
    @MainActor
    func exportAssignments(from course: Course) async -> (successCount: Int, failedTitles: [String]) {
        var successCount = 0
        var failedTitles: [String] = []

        // Get the user's default calendar
        guard let calendar = store.defaultCalendarForNewEvents else {
            return (0, course.assignments.map { $0.title })
        }

        for assignment in course.assignments {

            // Skip if already exported (prevents duplicates)
            if let existingID = assignment.calendarEventID, !existingID.isEmpty {
                successCount += 1
                continue
            }

            // Create a new calendar event
            let event = EKEvent(eventStore: store)
            event.title = "\(assignment.title) (\(course.name))"
            event.isAllDay = true
            event.startDate = assignment.dueDate
            event.endDate = assignment.dueDate
            event.notes = "Added by Sylly"
            event.calendar = calendar

            // Reminder: notify 1 day before the due date
            // -86400 = 86,400 seconds before the event (24 hours)
            // This triggers a Lock Screen notification automatically
            event.addAlarm(EKAlarm(relativeOffset: -86400))

            // Save the event to Apple Calendar
            do {
                try store.save(event, span: .thisEvent)
                // Store event ID on the assignment to prevent duplicates
                assignment.calendarEventID = event.eventIdentifier
                successCount += 1
            } catch {
                print("CalendarService: Failed to save \(assignment.title): \(error)")
                failedTitles.append(assignment.title)
            }
        }

        return (successCount, failedTitles)
    }
}
