//
//  ReviewView.swift
//  Sylly
//
//  Created by aryan on 1/30/26.
//

import SwiftUI

struct ReviewView: View {

    // MARK: - Environment & Navigation
    // @Environment(\.dismiss) provides a way to close/exit this view and return to previous screen
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties: Course Information
    // These hold the course data extracted from the scanned syllabus (will come from Claude API later)
    @State private var courseName = "Intro Artificial Intelligence"
    @State private var courseCode = "CAP 4630"
    @State private var courseIcon = "brain.head.profile"
    @State private var courseColor = "brandprimary"

    // MARK: - State Properties: Assignments List
    // Array of assignments extracted from the syllabus
    // Each assignment can be toggled (selected) to include/exclude from the course
    @State private var assignments: [ReviewAssignment] = [
        ReviewAssignment(title: "Midterm Exam", date: "Feb 12", type: "Exam", isSelected: false),
        ReviewAssignment(title: "Problem Set 3", date: "Feb 18", type: "Assignment", isSelected: true),
        ReviewAssignment(title: "Quiz 2", date: "Feb 24", type: "Quiz", isSelected: true),
        ReviewAssignment(title: "Final Project", date: "Mar 15", type: "Project", isSelected: true)
    ]

    // MARK: - State Properties: Sheet Management
    // Controls which modal sheets are presented
    @State private var showEditCourse = false
    @State private var showEditAssignment = false
    @State private var selectedAssignmentIndex: Int? = nil
    @State private var showSuccess = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Course Header Card
                // Displays course information with edit button
                HStack {
                    // Course icon with colored background
                    Image(systemName: courseIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color("BrandPrimary"))
                        .cornerRadius(10)

                    // Course name and code
                    VStack(alignment: .leading, spacing: 2) {
                        Text(courseName)
                            .font(.headline)
                        Text(courseCode)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Edit button - opens EditCourseSheet
                    Button(action: {
                        showEditCourse = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.primary)
                            .font(.system(size: 20, weight: .bold))
                            
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // MARK: - Assignments List
                // Scrollable list of assignments with toggle and edit functionality
                ScrollView {
                    VStack(spacing: 0) {
                        // Loop through each assignment
                        ForEach(Array(assignments.enumerated()), id: \.element.id) { index, assignment in
                            ReviewAssignmentRow(
                                assignment: $assignments[index],
                                onTap: {
                                    selectedAssignmentIndex = index
                                    showEditAssignment = true
                                }
                            )

                            // Divider between rows (except after last row)
                            if index < assignments.count - 1 {
                                Divider()
                                    .padding(.leading, 50)
                                    
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Add manually button - allows user to manually add assignments
                    Button(action: {
                        // TODO: Add new assignment manually
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add manually")
                        }
                        .foregroundColor(AppColors.primary)
                    }
                    .padding(.top, 12)
                }

                // MARK: - Bottom Button
                // Shows count of selected assignments and triggers success screen
                Button(action: {
                    showSuccess = true
                }) {
                    Text("Add \(selectedCount) Assignments")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            // MARK: - Navigation Bar
            // Cancel button in top left
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        // MARK: - Modal Sheets
        // EditCourseSheet: Allows editing course name, code, icon, and color
        .sheet(isPresented: $showEditCourse) {
            EditCourseSheet(
                courseName: $courseName,
                courseCode: $courseCode,
                courseIcon: $courseIcon,
                courseColor: $courseColor
            )
        }
        // EditAssignmentSheet: Allows editing selected assignment details
        .sheet(isPresented: $showEditAssignment) {
            if let index = selectedAssignmentIndex {
                EditAssignmentSheet(assignment: $assignments[index])
            }
        }
        // SuccessView: Shown after user confirms adding assignments
        .fullScreenCover(isPresented: $showSuccess) {
            SuccessView()
        }
    }

    // MARK: - Computed Property: Selected Count
    // Returns the number of assignments that are selected (isSelected = true)
    private var selectedCount: Int {
        assignments.filter { $0.isSelected }.count
    }
}

// MARK: - Review Assignment Model
// Temporary data model for assignments during review process
// Later will be replaced with actual Assignment model from SwiftData
struct ReviewAssignment: Identifiable {
    let id = UUID()
    var title: String
    var date: String
    var type: String
    var isSelected: Bool
}

// MARK: - Assignment Row Component
// Individual row in the assignments list with toggle and edit functionality
struct ReviewAssignmentRow: View {
    @Binding var assignment: ReviewAssignment
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Selection Circle
            // Toggle button that selects/deselects the assignment
            Button(action: {
                assignment.isSelected.toggle()
            }) {
                Image(systemName: assignment.isSelected ? "circle.fill" : "circle")
                    .foregroundColor(assignment.isSelected ? AppColors.primary : .gray)
                    .font(.title3)
            }

            // MARK: - Assignment Information
            // Title, date, and type in a vertical stack
            VStack(alignment: .leading, spacing: 2) {
                Text(assignment.title)
                    .font(.body)
                Text("\(assignment.date) · \(assignment.type)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // MARK: - Edit Chevron
            // Tap to open EditAssignmentSheet for this assignment
            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    ReviewView()
}
