//
//  EditAssignmentSheet.swift
//  Sylly
//

import SwiftUI
import UIKit

struct EditAssignmentSheet: View {

    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Binding var assignment: ReviewAssignment

    // Local state for editing
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var selectedType: String = "Exam"

    @State private var showDeleteAlert = false

    let types = ["Exam", "Quiz", "HW", "Project"]

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Assignment title", text: $title)
                }

                Section("Due") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Type") {
                    Picker("Assignment Type", selection: $selectedType) {
                        ForEach(types, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    // Without this the row keeps a label and squashes the control.
                    .labelsHidden()
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete this assignment")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
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
                    assignment.isSelected = false
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                }
            } message: {
                Text("This assignment will be removed from the list.")
            }
            .onAppear {
                title = assignment.title
                selectedType = assignment.type

                // Parse the assignment's date string into a Date object
                // so the DatePicker shows the actual due date, not today
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                if let parsed = dateFormatter.date(from: assignment.date) {
                    date = parsed
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Helper Functions
    private func saveAssignment() {
        assignment.title = title

        // Lead time was picked for the old type, so drop it and fall back to the ladder.
        if selectedType != assignment.type {
            assignment.leadDays = nil
        }

        assignment.type = selectedType

        // Convert date back to string format "YYYY-MM-dd"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        assignment.date = dateFormatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    EditAssignmentSheet(
        assignment: .constant(ReviewAssignment(
            title: "Midterm Exam",
            date: "Feb 12",
            type: "Exam",
            isSelected: true
        ))
    )
}
