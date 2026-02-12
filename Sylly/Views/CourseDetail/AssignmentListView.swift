//
//  AssignmentListView.swift
//  Sylly
//
//

import SwiftUI

struct AssignmentListView: View {
    let course: Course  // The course object passed from CourseDetailView
    let onAssignmentTap: (Assignment) -> Void  // Callback when an assignment row is tapped

    // MARK: - Computed Property: Upcoming Assignments
    // Get all assignments that are not completed AND due in the future, sorted by due date (earliest first)
    private var upcomingAssignments: [Assignment] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())  // Get today's date at midnight
        return course.assignments
            .filter { !$0.isCompleted && calendar.startOfDay(for: $0.dueDate) >= today }  // Not completed AND due date is today or later
            .sorted { $0.dueDate < $1.dueDate }  // Sort by date: earlier dates first
    }

    // MARK: - Computed Property: Overdue Assignments
    // Get all assignments that are not completed AND past their due date, sorted by due date (most overdue first)
    private var overdueAssignments: [Assignment] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())  // Get today's date at midnight
        return course.assignments
            .filter { !$0.isCompleted && calendar.startOfDay(for: $0.dueDate) < today }  // Not completed AND due date is before today
            .sorted { $0.dueDate < $1.dueDate }  // Sort by date: most overdue first
    }

    // MARK: - Computed Property: Completed Assignments
    // Get all assignments that are completed, also sorted by due date
    private var completedAssignments: [Assignment] {
        course.assignments
            .filter { $0.isCompleted }  // Keep only completed assignments
            .sorted { $0.dueDate < $1.dueDate }  // Sort by date: earliest dates first
    }
    
    var body: some View {
        // ScrollView allows this content to scroll if it's taller than the screen
        ScrollView {
            VStack(alignment: .leading, spacing: 16) { 
                
                // MARK: - UPCOMING Section
                // Only show this section if there are upcoming assignments
                if !upcomingAssignments.isEmpty {
                    // Section header label
                    Text("UPCOMING")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)  
                    
                    // Container for all upcoming assignment rows
                    VStack(spacing: 0) {
                        ForEach(upcomingAssignments) { assignment in
                            // Display each assignment as a row
                            AssignmentDetailRow(
                                assignment: assignment,
                                isCompleted: false,
                                onTap: { onAssignmentTap(assignment) }
                            )

                            // Add a divider line between rows (but NOT after the last row)
                            // .id is a unique identifier for each assignment
                            if assignment.id != upcomingAssignments.last?.id {
                                Divider()
                                    .padding(.leading, 40)  // Indent divider so it doesn't span full width
                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // MARK: - OVERDUE Section
                // Only show this section if there are overdue assignments
                if !overdueAssignments.isEmpty {
                    // Section header label
                    Text("OVERDUE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Container for all overdue assignment rows
                    VStack(spacing: 0) {
                        ForEach(overdueAssignments) { assignment in
                            // Display each assignment as a row
                            AssignmentDetailRow(
                                assignment: assignment,
                                isCompleted: false,
                                onTap: { onAssignmentTap(assignment) }
                            )

                            // Add a divider line between rows (but NOT after the last row)
                            if assignment.id != overdueAssignments.last?.id {
                                Divider()
                                    .padding(.leading, 40)  // Indent divider
                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // MARK: - COMPLETED Section
                // Only show this section if there are completed assignments
                if !completedAssignments.isEmpty {
                    // Section header label
                    Text("COMPLETED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)  
                    
                    // Container for all completed assignment rows
                    VStack(spacing: 0) {  // 0 spacing so dividers touch
                        ForEach(completedAssignments) { assignment in
                            // Display each assignment as a row
                            AssignmentDetailRow(
                                assignment: assignment,
                                isCompleted: true,
                                onTap: { onAssignmentTap(assignment) }
                            )

                            // Add a divider line between rows (but NOT after the last row)
                            if assignment.id != completedAssignments.last?.id {
                                Divider()
                                    .padding(.leading, 40)  // Indent divider
                            }
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)  
        }
    }
}

#Preview {
    // Create fake course data for testing
    let course = Course(
        name: "Intro to AI",
        code: "CAP 4630",
        icon: "brain.head.profile",
        color: "brandprimary"
    )

    // Create sample assignments with different states
    let overdueAssignment = Assignment(title: "Quiz 1", dueDate: Date(timeIntervalSinceNow: -86400 * 3), type: "quiz")  // 3 days ago
    let upcomingAssignment = Assignment(title: "Midterm Exam", dueDate: Date(timeIntervalSinceNow: 86400 * 5), type: "exam")  // 5 days from now
    let completedAssignment = Assignment(title: "Problem Set", dueDate: Date(timeIntervalSinceNow: -86400 * 10), type: "homework", isCompleted: true)  // 10 days ago (completed)

    // Add assignments to the course
    course.assignments = [overdueAssignment, upcomingAssignment, completedAssignment]
    
    // Return the view for preview
    return AssignmentListView(
        course: course,
        onAssignmentTap: { _ in }
    )
}
