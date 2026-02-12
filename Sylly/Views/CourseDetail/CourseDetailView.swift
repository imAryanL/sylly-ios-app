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

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var selectedAssignment: Assignment?
    @State private var showEditAssignmentSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Displays the course title, code, and assignment stats
            VStack(alignment: .leading, spacing: 4) {

                Text(course.name)
                    .font(.title)
                    .fontWeight(.bold)

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

            // MARK: - Main Content Section
            // Shows error state, empty state, or list of assignments (checks error first)
            if course.hasError {
                CourseErrorView()
            } else if course.assignments.isEmpty {
                EmptyCourseView()
            } else {
                AssignmentListView(
                    course: course,
                    onAssignmentTap: { assignment in
                        selectedAssignment = assignment
                        showEditAssignmentSheet = true
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
                    Button("Edit Course", action: {
                        showEditSheet = true
                    })
                    Button("Delete Course", role: .destructive, action: {
                        showDeleteAlert = true
                    })
                } label: {
                    Image(systemName: "ellipsis")  // Three dots icon
                        .foregroundColor(AppColors.primary)  // Make it blue
                }
            }
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
        .sheet(isPresented: $showEditAssignmentSheet) {
            if let assignment = selectedAssignment {
                EditAssignmentDetailSheet(assignment: assignment)
            }
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

    // MARK: - Delete Course Function
    private func deleteCourse() {
        // Remove the course from the model context
        modelContext.delete(course)

        do {
            try modelContext.save()
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
        CourseDetailView(course: course)
    }
}
