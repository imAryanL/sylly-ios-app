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
    @State private var time: Date = Date()
    @State private var selectedType: String = "Exam"

    @State private var showDeleteAlert = false

    let types = ["Exam", "Quiz", "HW", "Project"]

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

                            DatePicker("", selection: $date, displayedComponents: .date)
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

                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
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

                        Picker("Assignment Type", selection: $selectedType) {
                            ForEach(types, id: \.self) { type in
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
