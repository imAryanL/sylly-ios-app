//
//  CanvasMatchView.swift
//  Sylly
//
//  Screen where the student picks which Sylly course each Canvas course goes into.
//

import SwiftUI
import SwiftData

struct CanvasMatchView: View {

    // MARK: - Input
    let groups: [CanvasCourseGroup]
    let feedLink: String        // checked by Connect, saved here on Import

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // Same saved link Settings and ContentView read
    @AppStorage("canvasFeedLink") private var savedLink = ""

    // MARK: - Data
    @Query private var courses: [Course]

    // MARK: - State
    // Canvas course key → picked Sylly course, e.g. ["course_111": Orgo Lab]. Missing = Skip.
    @State private var picks: [String: Course] = [:]

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {

                // MARK: - Heading
                Text(headingText)
                    .font(.title2.bold())
                Text("Pick where each one goes in Sylly. You only do this once.")
                    .foregroundColor(.secondary)

                // MARK: - Course Cards
                VStack(spacing: 12) {
                    ForEach(groups, id: \.courseKey) { group in
                        courseCard(group)
                    }
                }
                .padding(.top, 20)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 12)
        }
        .background(Color(.systemGroupedBackground))
        // MARK: - Import Button
        // Pinned like Connect, so it never scrolls off
        .safeAreaInset(edge: .bottom) {
            Button {
                importAssignments()
            } label: {
                Text("Import assignments")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("Connect Canvas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                // Closes the whole sheet. Nothing is saved.
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onAppear {
            fillPicks()
        }
    }

    // MARK: - Import
    private func importAssignments() {
        // Step 1: Link each picked course to its Canvas course
        for group in groups {
            if let course = picks[group.courseKey] {
                course.canvasCourseID = group.courseKey
            }
        }

        // Step 2: Save the link. Kept even if every course was skipped, so they can match later.
        savedLink = feedLink

        // Step 3: Bring in the assignments. Skipped courses aren't linked, so saveItems leaves them out.
        var allItems: [CanvasItem] = []
        for group in groups {
            allItems.append(contentsOf: group.items)
        }
        CanvasService().saveItems(allItems, context: context)

        dismiss()
    }

    // MARK: - Starting Picks
    // Each card starts on its pre-pick from groupByCourse
    private func fillPicks() {
        for group in groups {
            if let suggestion = group.suggestedCourse {
                picks[group.courseKey] = suggestion
            }
        }
    }

    // MARK: - Free Courses
    // Courses linked to a different Canvas course are taken, so they stay out of the menu
    private var freeCourses: [Course] {
        var free: [Course] = []
        for course in courses {
            if course.canvasCourseID == nil {
                free.append(course)
            }
        }
        return free
    }

    // MARK: - Heading Text
    private var headingText: String {
        if groups.count == 1 {
            return "We found 1 course in Canvas"
        }
        return "We found \(groups.count) courses in Canvas"
    }

    // MARK: - Course Card
    // No Canvas course name: the feed only has codes like "xl_202720_EZ"
    private func courseCard(_ group: CanvasCourseGroup) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            pickMenu(for: group)

            VStack(alignment: .leading, spacing: 5) {
                // First two assignments only
                ForEach(group.items.prefix(2), id: \.canvasID) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 6, height: 6)
                        Text(item.title)
                            .font(.subheadline)
                    }
                }

                if group.items.count > 2 {
                    Text(moreText(for: group))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.leading, 14)
                }
            }
            .padding(.leading, 6)

            if picks[group.courseKey] == nil {
                Text("Not in Sylly yet. Scan its syllabus to add it.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Pick Menu
    // Tapping the pill lists the free courses, then Skip. A checkmark marks the current pick.
    private func pickMenu(for group: CanvasCourseGroup) -> some View {
        Menu {
            ForEach(freeCourses) { course in
                Button {
                    picks[group.courseKey] = course
                } label: {
                    if picks[group.courseKey] == course {
                        Label(course.name, systemImage: "checkmark")
                    } else {
                        Text(course.name)
                    }
                }
            }

            Divider()

            Button {
                picks[group.courseKey] = nil     // removing the key = Skip
            } label: {
                if picks[group.courseKey] == nil {
                    Label("Skip this course", systemImage: "checkmark")
                } else {
                    Text("Skip this course")
                }
            }
        } label: {
            pickLabel(for: group)
        }
    }

    // MARK: - Pick Label
    // The picked course's own icon and color, or a gray Skip
    private func pickLabel(for group: CanvasCourseGroup) -> some View {
        HStack(spacing: 10) {
            if let course = picks[group.courseKey] {
                Image(systemName: course.icon)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(AppColors.color(from: course.color))
                    .cornerRadius(8)
                Text(course.name)
                    .font(.headline)
                    .foregroundColor(.primary)
            } else {
                Image(systemName: "nosign")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray3))
                    .cornerRadius(8)
                Text("Skip this course")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.up.chevron.down")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - More Text
    // "+ 4 more assignments", or "+ 1 more assignment"
    private func moreText(for group: CanvasCourseGroup) -> String {
        let remaining = group.items.count - 2
        if remaining == 1 {
            return "+ 1 more assignment"
        }
        return "+ \(remaining) more assignments"
    }
}

// Fake courses so the layout shows up in Xcode
#Preview {
    // Test database with fake Sylly courses, so the menu has something to list
    let container = try! ModelContainer(for: Course.self, Assignment.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let orgoLab = Course(name: "Organic Chemistry Lab", code: "CHM 2211L")
    container.mainContext.insert(orgoLab)
    container.mainContext.insert(Course(name: "Organic Chemistry", code: "CHM 2210"))
    container.mainContext.insert(Course(name: "Introduction to Sociology", code: "SYG 2000"))

    // NavigationStack so the title shows
    return NavigationStack {
        CanvasMatchView(groups: [
            CanvasCourseGroup(courseKey: "course_1", items: [
                CanvasItem(canvasID: "1", title: "Post Lab Polymers", courseKey: "course_1", dueDate: .now),
                CanvasItem(canvasID: "2", title: "Lab Report 3", courseKey: "course_1", dueDate: .now),
                CanvasItem(canvasID: "3", title: "Lab Report 4", courseKey: "course_1", dueDate: .now)
            ], suggestedCourse: orgoLab),
            CanvasCourseGroup(courseKey: "course_2", items: [
                CanvasItem(canvasID: "4", title: "Chapter 18 Homework", courseKey: "course_2", dueDate: .now),
                CanvasItem(canvasID: "5", title: "Quiz 9", courseKey: "course_2", dueDate: .now)
            ], suggestedCourse: nil)
        ], feedLink: "")
    }
    .modelContainer(container)
}
