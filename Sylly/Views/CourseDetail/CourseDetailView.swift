//
//  CourseDetailView.swift
//  Sylly
//
//

import SwiftUI

struct CourseDetailView: View {
    let course: Course
    
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
                AssignmentListView(course: course)
            }
            
            // Push the rescan button to the bottom
            Spacer()
            
            // MARK: - Rescan Button
            // Button to re-scan the syllabus PDF (functionality added later)
            Button(action: {
                // TODO: Connect to scanner view
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "document.viewfinder.fill")
                    Text("Rescan Syllabus")
                }
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 80)
            .padding(.bottom, 20)
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            // MARK: - Top Right Menu Button
            // Three-dot menu for edit/delete options
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {  // Creates a dropdown menu
                    Button("Edit Course", action: {}) // No functionality for edit button yet
                    Button("Delete Course", role: .destructive, action: {}) // No functionality for delete button yet
                } label: {
                    Image(systemName: "ellipsis")  // Three dots icon
                        .foregroundColor(AppColors.primary)  // Make it blue
                }
            }
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
