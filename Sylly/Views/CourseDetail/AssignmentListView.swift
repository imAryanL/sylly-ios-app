//
//  AssignmentListView.swift
//  Sylly
//
//

import SwiftUI

struct AssignmentListView: View {
    let course: Course  // The course object passed from CourseDetailView

    // MARK: - Computed Property: Upcoming Assignments
    // Get all assignments that are not completed, sorted by due date (earliest first)
    private var upcomingAssignments: [Assignment] {
        course.assignments
            .filter { !$0.isCompleted }  // Keep only assignments where isCompleted is false
            .sorted { $0.dueDate < $1.dueDate }  // Sort by date: earlier dates first
    }
    
    // MARK: - Computed Property: Completed Assignments
    // Get all assignments that are completed, also sorted by due date
    private var completedAssignments: [Assignment] {
        course.assignments
            .filter { $0.isCompleted }  // Keep only completed assignments
            .sorted { $0.dueDate < $1.dueDate }  // Sort by date: earlier dates first
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
                            AssignmentDetailRow(assignment: assignment, isCompleted: false)

                            // Add a divider line between rows (but NOT after the last row)
                            // .id is a unique identifier for each assignment
                            if assignment.id != upcomingAssignments.last?.id {
                                Divider()
                                    .padding(.leading, 40)  // Indent divider so it doesn't span full width
                            }
                        }
                    }
                    .background(Color.white)
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
                            AssignmentDetailRow(assignment: assignment, isCompleted: true)

                            // Add a divider line between rows (but NOT after the last row)
                            if assignment.id != completedAssignments.last?.id {
                                Divider()
                                    .padding(.leading, 40)  // Indent divider
                            }
                        }
                    }
                    .background(Color.white)
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
    
    // Create sample assignments
    let assignment1 = Assignment(title: "Midterm Exam", dueDate: Date(), type: "exam")
    let assignment2 = Assignment(title: "Quiz 1", dueDate: Date(), type: "quiz", isCompleted: true)
    
    // Add assignments to the course
    course.assignments = [assignment1, assignment2]
    
    // Return the view for preview
    return AssignmentListView(course: course)
}
