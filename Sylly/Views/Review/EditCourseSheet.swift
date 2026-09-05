//
//  EditCourseSheet.swift
//  Sylly
//

import SwiftUI

struct EditCourseSheet: View {
    
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    
    @Binding var courseName: String
    @Binding var courseCode: String
    @Binding var courseIcon: String
    @Binding var courseColor: String

    // Edit copies. The bindings point straight at ReviewView's values, so editing
    // them directly is what made Cancel do nothing — there was no original left
    // to go back to. These get written back only on Save.
    @State private var draftName: String = ""
    @State private var draftCode: String = ""
    @State private var draftIcon: String = ""
    @State private var draftColor: String = ""

    // Lets a tap anywhere in the row open the keyboard, not just on the text itself.
    private enum CourseField {
        case name
        case code
    }
    @FocusState private var focusedField: CourseField?
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        Image(systemName: draftIcon)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(AppColors.color(from: draftColor))
                            .cornerRadius(16)
                        Spacer()
                    }
                    // No card behind the preview — it is the result, not a control.
                    .listRowBackground(Color.clear)
                }

                Section("Course") {
                    // Label above, not beside — a course name is free text and would
                    // otherwise run into the label on a narrower phone.
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Course name", text: $draftName)
                            .focused($focusedField, equals: .name)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .name
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Code")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        TextField("Course code", text: $draftCode)
                            .focused($focusedField, equals: .code)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .code
                    }
                }

                Section("Color") {
                    ColorPickerRow(selectedColor: $draftColor)
                }

                Section("Icon") {
                    IconPickerGrid(selectedIcon: $draftIcon, selectedColor: draftColor)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Edit course")
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
                        courseName = draftName
                        courseCode = draftCode
                        courseIcon = draftIcon
                        courseColor = draftColor
                        dismiss()
                    }
                    .foregroundColor(draftName.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : AppColors.primary)
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                draftName = courseName
                draftCode = courseCode
                draftIcon = courseIcon
                draftColor = courseColor
            }
        }
    }
}

// MARK: - Icon Picker Grid
struct IconPickerGrid: View {
    @Binding var selectedIcon: String
    let selectedColor: String

    // Pull icons from the single source of truth in Constants.swift
    let icons = AppIcons.courseIcons

    let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 6)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(icons, id: \.self) { icon in
                Button(action: {
                    selectedIcon = icon
                }) {
                    Image(systemName: icon)
                        .font(.title3)
                        // Selection uses the course colour, so the grid shows the real result.
                        .foregroundColor(selectedIcon == icon ? .white : .primary)
                        .frame(width: 44, height: 44)
                        .background(selectedIcon == icon ? AppColors.color(from: selectedColor) : Color.gray.opacity(0.12))
                        .cornerRadius(10)
                }
                // Without this the whole row becomes one button.
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Color Picker Row
struct ColorPickerRow: View {
    @Binding var selectedColor: String
    
    // Split into 2 rows of 5 colors each
    let topColors = ["brandprimary", "red", "green", "orange", "yellow"]
    let bottomColors = ["pink", "purple", "blue", "black", "gray"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Top row
            HStack(spacing: 12) {
                ForEach(topColors, id: \.self) { color in
                    colorButton(for: color)
                }
            }
            
            // Bottom row
            HStack(spacing: 12) {
                ForEach(bottomColors, id: \.self) { color in
                    colorButton(for: color)
                }
            }
        }
    }

    // Reusable color button
    private func colorButton(for color: String) -> some View {
        Button(action: {
            selectedColor = color
        }) {
            ZStack {
                Circle()
                    .fill(AppColors.color(from: color))
                    .frame(width: 35, height: 35)

                if selectedColor == color {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    EditCourseSheet(
        courseName: .constant("Intro Artificial Intelligence"),
        courseCode: .constant("CAP 4630"),
        courseIcon: .constant("brain.head.profile"),
        courseColor: .constant("brandprimary")
    )
}

