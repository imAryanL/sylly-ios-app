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
    @State private var selectedAssignmentIndex: AssignmentIndex? = nil
    @State private var showSuccess = false

    // MARK: - State Properties: Error Handling
    // Tracks assignments that failed to save due to bad dates
    @State private var showDateError = false
    @State private var failedAssignmentNames: [String] = []
    @State private var savedCourse: Course? = nil  // Holds course for the error alert path

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
                        .background(AppColors.color(from: courseColor))
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
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // MARK: - Assignments List
                ScrollView {
                    if assignments.isEmpty {
                        // MARK: - Empty State
                        // Shown when Claude couldn't find any dated assignments
                        // (e.g. syllabus lists "3 exams" but no specific dates)
                        VStack(spacing: 12) {
                            Image("SyllySad")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130, height: 130)
                                .padding(.top, 32)

                            Text("No dated assignments found")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("This syllabus may not have specific\ndue dates listed. You can add\nassignments manually below.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(assignments.enumerated()), id: \.element.id) { index, assignment in
                                ReviewAssignmentRow(
                                    assignment: $assignments[index],
                                    onTap: {
                                        selectedAssignmentIndex = AssignmentIndex(id: index)
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
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }

                    // Add manually button (always visible)
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
                        navigationState = .home
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
        // Uses .sheet(item:) instead of .sheet(isPresented:) to avoid
        // a SwiftUI race condition where the sheet opens before the
        // index is set, causing a blank screen on first tap
        .sheet(item: $selectedAssignmentIndex) { selected in
            EditAssignmentSheet(assignment: $assignments[selected.id])
        }
        // Alert when some assignments had unparseable dates
        .alert("Some Dates Couldn't Be Read", isPresented: $showDateError) {
            Button("OK") {
                if let course = savedCourse {
                    // Some assignments saved successfully — go to success
                    let savedCount = selectedCount - failedAssignmentNames.count
                    navigationState = .success(savedCount, course)
                } else {
                    // All assignments failed — no course was saved, go home
                    navigationState = .home
                }
            }
        } message: {
            let names = failedAssignmentNames.joined(separator: ", ")
            if savedCourse != nil {
                Text("These assignments were skipped because their dates couldn't be understood:\n\n\(names)\n\nYou can add them manually later.")
            } else {
                Text("None of the assignments could be saved because their dates couldn't be understood:\n\n\(names)\n\nPlease try scanning again or add assignments manually.")
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

    // MARK: - Save to Database
    private func saveToDatabase() {
        // Create the Course object
        let course = Course(
            name: courseName,
            code: courseCode,
            icon: courseIcon,
            color: courseColor
        )

        // Track any assignments with dates that can't be parsed
        var failed: [String] = []
        var savedCount = 0

        // Create Assignment objects for selected items only
        for reviewAssignment in assignments where reviewAssignment.isSelected {
            // Convert date string to Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            guard let dueDate = dateFormatter.date(from: reviewAssignment.date) else {
                // Track this failure instead of silently skipping
                failed.append(reviewAssignment.title)
                continue
            }

            // Convert display type back to database format
            // "HW" → "homework", everything else just lowercased
            let type = reviewAssignment.type == "HW" ? "homework" : reviewAssignment.type.lowercased()

            // Create the Assignment
            let assignment = Assignment(
                title: reviewAssignment.title,
                dueDate: dueDate,
                type: type
            )

            // Link assignment to course
            assignment.course = course
            course.assignments.append(assignment)
            savedCount += 1
        }

        // Only save if at least one assignment was successfully parsed
        // This prevents "ghost" courses with zero assignments
        if savedCount == 0 && !failed.isEmpty {
            failedAssignmentNames = failed
            showDateError = true
            return
        }

        // Save to SwiftData
        modelContext.insert(course)

        do {
            try modelContext.save()
        } catch {
            print("Error saving to database: \(error)")
            return
        }

        // Store course in @State so the error alert closure can reach it
        savedCourse = course

        // If some assignments had bad dates, warn the user
        if !failed.isEmpty {
            failedAssignmentNames = failed
            showDateError = true
        } else {
            // All good — go to success screen with the Course for calendar export
            navigationState = .success(savedCount, course)
        }
    }
}

// MARK: - Assignment Index Wrapper
// Small helper so .sheet(item:) can work with an array index
// (Int alone isn't Identifiable, so this wraps it)
struct AssignmentIndex: Identifiable {
    let id: Int
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
