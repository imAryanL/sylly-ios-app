//
//  EditAssignmentDetailSheet.swift
//  Sylly
//

import SwiftUI
import SwiftData
import UIKit

struct EditAssignmentDetailSheet: View {

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var dueDate: Date = Date()
    @State private var assignmentTime: Date = Date()
    @State private var assignmentType: String = "homework"
    @State private var isCompleted: Bool = false

    @State private var showDeleteAlert = false

    let assignment: Assignment
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

                    // MARK: - Assignment Type (Glassmorphism)
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

                    Spacer()
                        .frame(height: 12)

                    // MARK: - Completion Toggle
                    Button(action: {
                        isCompleted.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .font(.headline)
                                .foregroundColor(isCompleted ? AppColors.primary : .gray)
                            Text(isCompleted ? "Mark as Incomplete" : "Mark as Completed")
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // MARK: - Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash")
                            Text("Delete this assignment")
                                .font(.headline)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ultraThickMaterial)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("Edit assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAssignment()
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        dismiss()
                    }
                    .foregroundColor(title.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : AppColors.primary)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("Delete Assignment?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAssignment()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                }
            } message: {
                Text("This assignment will be deleted from the course.")
            }
            .onAppear {
                title = assignment.title
                dueDate = assignment.dueDate
                assignmentTime = assignment.dueDate
                isCompleted = assignment.isCompleted

                // Map the stored lowercase type to the picker's display format
                // Database stores: "exam", "quiz", "homework", "project"
                // Picker expects: "Exam", "Quiz", "HW", "Project"
                switch assignment.type.lowercased() {
                case "homework", "hw":
                    assignmentType = "HW"
                case "exam":
                    assignmentType = "Exam"
                case "quiz":
                    assignmentType = "Quiz"
                case "project":
                    assignmentType = "Project"
                default:
                    assignmentType = assignment.type
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helper Functions
    private func saveAssignment() {
        // Step 1: Update basic assignment fields from the edit form
        assignment.title = title
        // Convert picker display format back to lowercase for database
        // "HW" -> "homework", everything else just lowercased
        assignment.type = assignmentType == "HW" ? "homework" : assignmentType.lowercased()
        assignment.isCompleted = isCompleted

        // Step 2: Separate date and time into individual components
        // The date picker and time picker work independently, so I need to combine them
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: assignmentTime)

        // Step 3: Merge date and time components back together
        // Create a new DateComponents object with both date (year/month/day) and time (hour/minute)
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        // Step 4: Convert combined components back to a single Date object for the database
        // ?? dueDate means "if conversion fails, use the original date as fallback"
        assignment.dueDate = calendar.date(from: combinedComponents) ?? dueDate

        // Step 5: Save the updated assignment to the SwiftData database
        // do/try/catch is error handling - if save fails, it prints the error
        do {
            try modelContext.save()
        } catch {
            print("Error saving assignment: \(error)")
        }
    }

    private func deleteAssignment() {
        // Step 1: Remove the assignment from the database
        modelContext.delete(assignment)

        // Step 2: Commit the deletion to the database
        // do/try/catch is error handling - if deletion fails, it prints the error
        do {
            try modelContext.save()
        } catch {
            print("Error deleting assignment: \(error)")
        }
    }
}

// MARK: - Preview
#Preview {
    EditAssignmentDetailSheet(
        assignment: Assignment(
            title: "Midterm Exam",
            dueDate: Date(),
            type: "exam"
        )
    )
}
