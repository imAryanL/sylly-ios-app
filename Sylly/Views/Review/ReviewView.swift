//
//  ReviewView.swift
//  Sylly
//
//  This view shows the parsed syllabus data for user review
//  Users can edit course info, toggle assignments, and save to database
//

import SwiftUI
import SwiftData

struct ReviewView: View {

    // MARK: - Properties
    let parsedSyllabus: ParsedSyllabus

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext  // Database access
    @Environment(\.dismiss) private var dismiss  // For closing sheets

    // MARK: - State Properties: Course Information
    // These are editable by the user
    @State private var courseName: String = ""
    @State private var courseCode: String = ""
    @State private var courseIcon: String = "book.closed.fill"
    @State private var courseColor: String = "brandprimary"

    // MARK: - State Properties: Assignments
    // Converted from ParsedAssignment to ReviewAssignment (with selection toggle)
    @State private var assignments: [ReviewAssignment] = []

    // MARK: - State Properties: Sheets & Navigation
    @State private var showEditCourse = false
    @State private var showEditAssignment = false
    @State private var selectedAssignmentIndex: Int? = nil
    @State private var showSuccess = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Course Header Card
                HStack {
                    // Course icon with colored background
                    Image(systemName: courseIcon)
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(getColor(from: courseColor))
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

                    // Edit button
                    Button(action: {
                        showEditCourse = true
                    }) {
                        Image(systemName: "pencil")
                            .foregroundColor(AppColors.primary)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // MARK: - Assignments List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(Array(assignments.enumerated()), id: \.element.id) { index, assignment in
                            ReviewAssignmentRow(
                                assignment: $assignments[index],
                                onTap: {
                                    selectedAssignmentIndex = index
                                    showEditAssignment = true
                                }
                            )

                            // Divider between rows
                            if index < assignments.count - 1 {
                                Divider()
                                    .foregroundColor(.secondary.opacity(0.3))
                                    .padding(.leading, 50)
                            }
                        }
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Add manually button
                    Button(action: {
                        addManualAssignment()
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
                Button(action: {
                    saveToDatabase()
                }) {
                    Text("Add \(selectedCount) Assignments")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCount > 0 ? AppColors.primary : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(selectedCount == 0)
                .padding()
            }
            .background(AppColors.background)
            .navigationTitle("Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }

        // MARK: - Initialize Data on Appear
        .onAppear {
            setupData()
        }

        // MARK: - Sheets
        .sheet(isPresented: $showEditCourse) {
            EditCourseSheet(
                courseName: $courseName,
                courseCode: $courseCode,
                courseIcon: $courseIcon,
                courseColor: $courseColor
            )
        }
        .sheet(isPresented: $showEditAssignment) {
            if let index = selectedAssignmentIndex {
                EditAssignmentSheet(assignment: $assignments[index])
            }
        }
    }

    // MARK: - Computed Properties

    // Count of selected assignments
    private var selectedCount: Int {
        assignments.filter { $0.isSelected }.count
    }

    // MARK: - Helper Functions

    // Set up initial data from parsed syllabus
    private func setupData() {
        // Set course info
        courseName = parsedSyllabus.courseName
        courseCode = parsedSyllabus.courseCode

        // Convert ParsedAssignments to ReviewAssignments
        assignments = parsedSyllabus.assignments.map { parsed in
            ReviewAssignment(
                title: parsed.title,
                date: parsed.date,
                type: capitalizeType(parsed.type),
                isSelected: true  // Select all by default
            )
        }

        // Auto-select an icon based on course name
        courseIcon = suggestIcon(for: courseName)
    }

    // Capitalize assignment type for display
    private func capitalizeType(_ type: String) -> String {
        switch type.lowercased() {
        case "exam": return "Exam"
        case "quiz": return "Quiz"
        case "homework": return "HW"
        case "project": return "Project"
        default: return type.capitalized
        }
    }

    // Suggest an icon based on course name keywords
    private func suggestIcon(for name: String) -> String {
        let lowercased = name.lowercased()

        if lowercased.contains("math") || lowercased.contains("calculus") || lowercased.contains("algebra") {
            return "function"
        } else if lowercased.contains("computer") || lowercased.contains("programming") || lowercased.contains("software") {
            return "laptopcomputer"
        } else if lowercased.contains("chemistry") {
            return "flask.fill"
        } else if lowercased.contains("biology") || lowercased.contains("life science") {
            return "leaf.fill"
        } else if lowercased.contains("physics") {
            return "atom"
        } else if lowercased.contains("english") || lowercased.contains("writing") || lowercased.contains("literature") {
            return "text.book.closed.fill"
        } else if lowercased.contains("history") || lowercased.contains("government") {
            return "building.columns.fill"
        } else if lowercased.contains("psychology") || lowercased.contains("ai") || lowercased.contains("artificial intelligence") {
            return "brain.head.profile"
        } else if lowercased.contains("music") {
            return "music.note"
        } else if lowercased.contains("art") {
            return "paintpalette.fill"
        } else if lowercased.contains("business") || lowercased.contains("economics") {
            return "chart.bar.fill"
        } else if lowercased.contains("health") || lowercased.contains("nursing") {
            return "stethoscope"
        } else {
            return "book.closed.fill"  // Default icon
        }
    }

    // Add a blank assignment manually
    private func addManualAssignment() {
        let newAssignment = ReviewAssignment(
            title: "New Assignment",
            date: formatDate(Date()),
            type: "HW",
            isSelected: true
        )
        assignments.append(newAssignment)
    }

    // Format date as "YYYY-MM-DD"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    // Convert color name to Color
    private func getColor(from colorName: String) -> Color {
        switch colorName.lowercased() {
        case "brandprimary": return Color("BrandPrimary")
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        case "blue": return Color("ICON_Blue")
        case "pink": return Color("ICON_Pink")
        case "purple": return Color("ICON_Purple")
        case "yellow": return .yellow
        case "black": return .black
        case "gray": return .gray
        default: return Color("BrandPrimary")
        }
    }

    // MARK: - Save to Database
    private func saveToDatabase() {
        // Create the Course object
        let course = Course(
            name: courseName,
            code: courseCode,
            icon: courseIcon,
            color: courseColor
        )

        // Create Assignment objects for selected items only
        for reviewAssignment in assignments where reviewAssignment.isSelected {
            // Convert date string to Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dueDate = dateFormatter.date(from: reviewAssignment.date) ?? Date()

            // Convert type to lowercase for database
            let type = reviewAssignment.type.lowercased()

            // Create the Assignment
            let assignment = Assignment(
                title: reviewAssignment.title,
                dueDate: dueDate,
                type: type
            )

            // Link assignment to course
            assignment.course = course
            course.assignments.append(assignment)
        }

        // Save to SwiftData
        modelContext.insert(course)

        do {
            try modelContext.save()
        } catch {
            print("Error saving to database: \(error)")
            return
        }

        // Navigate to success screen
        navigationState = .success(selectedCount)
    }
}

// MARK: - Review Assignment Model
// Temporary model for the review screen (not saved to database)
struct ReviewAssignment: Identifiable {
    let id = UUID()
    var title: String
    var date: String       // Format: "YYYY-MM-DD"
    var type: String       // "Exam", "Quiz", "HW", "Project"
    var isSelected: Bool
}

// MARK: - Assignment Row Component
struct ReviewAssignmentRow: View {
    @Binding var assignment: ReviewAssignment
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Selection toggle
            Button(action: {
                assignment.isSelected.toggle()
            }) {
                Image(systemName: assignment.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(assignment.isSelected ? AppColors.primary : .gray)
                    .font(.title2)
            }

            // Assignment info
            VStack(alignment: .leading, spacing: 2) {
                Text(assignment.title)
                    .font(.body)
                    .foregroundColor(assignment.isSelected ? .primary : .secondary)

                Text("\(formatDisplayDate(assignment.date)) · \(assignment.type)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Edit chevron
            Button(action: onTap) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
    }

    // Convert "2025-02-12" to "Feb 12"
    private func formatDisplayDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}

// MARK: - Preview
#Preview {
    // Create sample parsed data for preview
    let sampleSyllabus = ParsedSyllabus(
        courseName: "Intro to Artificial Intelligence",
        courseCode: "CAP 4630",
        assignments: [
            ParsedAssignment(title: "Midterm Exam", date: "2025-02-12", type: "exam"),
            ParsedAssignment(title: "Problem Set 3", date: "2025-02-18", type: "homework"),
            ParsedAssignment(title: "Quiz 2", date: "2025-02-24", type: "quiz"),
            ParsedAssignment(title: "Final Project", date: "2025-03-15", type: "project")
        ]
    )

    ReviewView(
        parsedSyllabus: sampleSyllabus,
        navigationState: .constant(.reviewing(sampleSyllabus))
    )
    .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
