//
//  AddAssignmentSheet.swift
//  Sylly
//
//  Sheet for manually adding a new assignment to an existing course.
//

import SwiftUI
import SwiftData
import UIKit

struct AddAssignmentSheet: View {

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // The course we're adding the assignment to
    let course: Course

    // MARK: - State Properties
    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var assignmentTime: Date = Date()
    @State private var assignmentType: String = "HW"
    @State private var showSaveError: Bool = false

    let assignmentTypes = ["Exam", "Quiz", "HW", "Project"]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        TextField("Assignment title", text: $title)
                            .font(.headline)
                            .padding(12)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // MARK: - Date & Time Section
                    VStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            DatePicker("", selection: $dueDate, displayedComponents: .date)
                                .labelsHidden()
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time (optional)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)

                            DatePicker("", selection: $assignmentTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(12)
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Assignment Type Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Type")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Picker("Assignment Type", selection: $assignmentType) {
                            ForEach(assignmentTypes, id: \.self) { type in
                                Text(type)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(16)
                        .background(.thinMaterial)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("New assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        // Only dismiss if save succeeds — otherwise show error alert
                        if addAssignment() {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            dismiss()
                        } else {
                            showSaveError = true
                        }
                    }
                    .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : AppColors.primary)
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        // Show alert if saving to SwiftData fails
        .alert("Couldn't Save", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Something went wrong saving this assignment. Please try again.")
        }
    }

    // MARK: - Helper Functions
    // Returns true if save succeeded, false if it failed
    private func addAssignment() -> Bool {
        // Step 1: Combine the date and time pickers into a single Date
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: assignmentTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        let finalDate = calendar.date(from: combinedComponents) ?? dueDate

        // Step 2: Convert picker display format to lowercase for database
        // "HW" -> "homework", everything else just lowercased
        let dbType = assignmentType == "HW" ? "homework" : assignmentType.lowercased()

        // Step 3: Create the new assignment and link it to the course
        let newAssignment = Assignment(title: title, dueDate: finalDate, type: dbType)
        newAssignment.course = course
        course.assignments.append(newAssignment)

        // Step 4: Save to SwiftData
        do {
            try modelContext.save()
            return true
        } catch {
            print("Error saving new assignment: \(error)")
            return false
        }
    }
}

// MARK: - Preview
#Preview {
    AddAssignmentSheet(
        course: Course(
            name: "Intro to AI",
            code: "CAP 4630",
            icon: "brain.head.profile",
            color: "brandprimary"
        )
    )
}
