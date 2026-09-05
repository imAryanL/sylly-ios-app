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
    // Starts at 11:59 PM rather than "right now" — a deadline of 9:52 PM
    // just because that's when you typed it in makes no sense.
    @State private var assignmentTime: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date()) ?? Date()
    @State private var hasTime: Bool = false
    @State private var assignmentType: String = "HW"
    @State private var showSaveError: Bool = false

    let assignmentTypes = ["Exam", "Quiz", "HW", "Project"]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Assignment title", text: $title)
                }

                Section("Due") {
                    DatePicker("Date", selection: $dueDate, displayedComponents: .date)

                    Toggle("Set a time", isOn: $hasTime)
                        .tint(AppColors.primary)

                    if hasTime {
                        DatePicker("Time", selection: $assignmentTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Type") {
                    Picker("Assignment Type", selection: $assignmentType) {
                        ForEach(assignmentTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Without this the row keeps a label and squashes the control.
                    .labelsHidden()
                }
            }
            .scrollDismissesKeyboard(.interactively)
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

        if hasTime {
            combinedComponents.hour = timeComponents.hour
            combinedComponents.minute = timeComponents.minute
        } else {
            // Toggle off means no time given — store midnight, same as a fresh scan
            combinedComponents.hour = 0
            combinedComponents.minute = 0
        }

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
            NotificationService.shared.refreshAll(context: modelContext)
            return true
        } catch {
            // Take the new assignment back out of memory — it was appended to the
            // course before the save, so tapping Add again would make a second one
            modelContext.rollback()
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
