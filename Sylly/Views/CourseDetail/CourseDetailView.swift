//
//  CourseDetailView.swift
//  Sylly
//
//

import SwiftUI
import SwiftData

struct CourseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let course: Course
    // Navigation binding so I can trigger the scanner from here
    @Binding var navigationState: NavigationState

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var selectedAssignment: Assignment?
    @State private var showAddAssignmentSheet = false
    @State private var showCourseInfo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Displays the course title, code, and assignment stats
            VStack(alignment: .leading, spacing: 4) {

                Text(course.name)
                    .font(.title)
                    .fontWeight(.bold)
                    // The screen is a VStack, so opening Course info squeezes the
                    // header and truncates the name. This keeps its full height.
                    .fixedSize(horizontal: false, vertical: true)

                Text(course.code)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)

                // Assignment count with remaining count
                // Example: "8 Assignments • 4 Remaining"
                HStack(spacing: 0) {
                    Text("\(totalAssignments) Assignments • ")
                        .foregroundColor(.secondary)
                    Text("\(remainingAssignments) Remaining")
                        .foregroundColor(AppColors.primary)
                }
                .font(.subheadline)
                .padding(.top, 4)
            }
            .padding()

            // MARK: - Course Info
            // Whatever the syllabus stated. The whole row is gone when it stated nothing,
            // so a course scanned before this existed looks exactly like it used to.
            if !courseInfoFields.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCourseInfo.toggle()
                        }
                    }) {
                        HStack {
                            Text("Course info")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.8))
                                .rotationEffect(.degrees(showCourseInfo ? 90 : 0))
                        }
                    }

                    if showCourseInfo {
                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(courseInfoFields, id: \.label) { field in
                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 5) {
                                        Image(systemName: field.icon)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        Text(field.label)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white.opacity(0.85))
                                    }

                                    Text(field.value)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        // Lets a long policy wrap instead of cutting off at one line
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.top, 14)
                    }
                }
                // Fixed brand fill, so the text is hardcoded white rather than .primary,
                // which would flip to black in dark mode and vanish.
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }

            // MARK: - Main Content Section
            // Shows error state, empty state, or list of assignments (checks error first)
            if course.hasError {
                CourseErrorView(onRescan: {
                    // Go back to the previous screen, then open the scanner
                    dismiss()
                    navigationState = .scanning
                })
            } else if course.assignments.isEmpty {
                EmptyCourseView()
            } else {
                AssignmentListView(
                    course: course,
                    onAssignmentTap: { assignment in
                        selectedAssignment = assignment
                    }
                )
            }

        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            // MARK: - Top Right Menu Button
            // Three-dot menu for edit/delete options
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {  // Creates a dropdown menu
                    Button(action: {
                        showAddAssignmentSheet = true
                    }) {
                        Label("Add Assignment", systemImage: "plus")
                    }
                    Button(action: {
                        showEditSheet = true
                    }) {
                        Label("Edit Course", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete Course", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")  // Three dots icon
                        .foregroundColor(AppColors.primary)  // Make it blue
                }
            }
        }

        // MARK: - Add Assignment Sheet
        .sheet(isPresented: $showAddAssignmentSheet) {
            AddAssignmentSheet(course: course)
        }

        // MARK: - Edit Course Sheet
        .sheet(isPresented: $showEditSheet) {
            EditCourseSheet(
                courseName: Binding(
                    get: { course.name },
                    set: { course.name = $0 }
                ),
                courseCode: Binding(
                    get: { course.code },
                    set: { course.code = $0 }
                ),
                courseIcon: Binding(
                    get: { course.icon },
                    set: { course.icon = $0 }
                ),
                courseColor: Binding(
                    get: { course.color },
                    set: { course.color = $0 }
                )
            )
        }

        // MARK: - Edit Assignment Sheet
        // Uses .sheet(item:) instead of .sheet(isPresented:) to avoid a SwiftUI race condition where the sheet opens before
        // selectedAssignment is set, causing a blank screen on first tap
        .sheet(item: $selectedAssignment) { assignment in
            EditAssignmentDetailSheet(assignment: assignment)
        }

        // MARK: - Delete Confirmation Alert
        .alert("Delete Course?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCourse()
            }
        } message: {
            Text("Are you sure you want to delete \(course.name) and all its assignments? This cannot be undone.")
        }
    }

    // MARK: - Helper Computed Properties
    // Count the total number of assignments for this course
    private var totalAssignments: Int {
        course.assignments.count  // .count gives you number of items in the array as a whole number
    }

    // Count only the assignments that are NOT completed yet
    private var remainingAssignments: Int {
        // .filter keeps only items where the condition is true
        // !$0.isCompleted means "where isCompleted is false"
        course.assignments.filter { !$0.isCompleted }.count
    }

    // Only the info the syllabus actually stated, in the order it should show up.
    // Empty means the whole Course info row stays hidden.
    // Icons picked for distinct silhouettes — tall, humanoid, round. Two circles
    // next to each other were unreadable at this size.
    private var courseInfoFields: [(label: String, value: String, icon: String)] {
        var fields: [(label: String, value: String, icon: String)] = []

        if let officeHours = course.officeHours {
            fields.append((label: "Office hours", value: officeHours, icon: "person.fill"))
        }
        if let latePolicy = course.latePolicy {
            fields.append((label: "Late work", value: latePolicy, icon: "hourglass"))
        }
        if let gradingBreakdown = course.gradingBreakdown {
            fields.append((label: "Grading", value: gradingBreakdown, icon: "chart.pie.fill"))
        }

        return fields
    }

    // MARK: - Delete Course Function
    private func deleteCourse() {
        // Remove the course from the model context
        modelContext.delete(course)

        do {
            try modelContext.save()
            NotificationService.shared.refreshAll(context: modelContext)
            // Go back to previous screen after successful deletion
            dismiss()
        } catch {
            print("Error deleting course: \(error)")
        }
    }
}

#Preview {
    // This creates fake data to preview the screen in Xcode
    let course = Course(
        name: "Intro to Artificial Intelligence",
        code: "CAP 4630",
        icon: "brain.head.profile",
        color: "brandprimary"
    )

    // Create sample assignments to test with
    let assignment1 = Assignment(title: "Midterm Exam", dueDate: Date(), type: "exam")
    let assignment2 = Assignment(title: "Problem Set 3", dueDate: Date(), type: "homework")
    let assignment3 = Assignment(title: "Quiz 2", dueDate: Date(), type: "quiz")
    let assignment4 = Assignment(title: "Quiz 1", dueDate: Date(), type: "quiz", isCompleted: true)

    // Add the assignments to the course
    course.assignments = [assignment1, assignment2, assignment3, assignment4]

    // Preview wrapped in NavigationStack so back button works
    return NavigationStack {
        CourseDetailView(course: course, navigationState: .constant(.home))
    }
}
