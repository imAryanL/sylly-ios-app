//
//  EditAssignmentSheet.swift
//  Sylly
//

import SwiftUI

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
                VStack(spacing: 16) {
                    
                    // MARK: - Title Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Assignment title", text: $title)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Date Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // MARK: - Time Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time (optional)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // MARK: - Assignment Type Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assignment Type")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(types, id: \.self) { type in
                                Button(action: {
                                    selectedType = type
                                }) {
                                    Text(type)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedType == type ? AppColors.primary : Color.gray.opacity(0.1))
                                        .foregroundColor(selectedType == type ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // MARK: - Delete Card
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete this assignment")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
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
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .alert("Delete Assignment?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("This assignment will be removed from the list.")
            }
            .onAppear {
                title = assignment.title
                selectedType = assignment.type
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Functions
    private func saveAssignment() {
        assignment.title = title
        assignment.type = selectedType
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
