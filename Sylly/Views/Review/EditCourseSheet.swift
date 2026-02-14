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
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Course Icon Preview
                    Image(systemName: courseIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(AppColors.color(from: courseColor))
                        .cornerRadius(16)
                        .padding(.top, 20)
                    
                    // MARK: - Course Name
                    VStack(alignment: .center, spacing: 6) {
                        Text("Course Name")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        VStack(spacing: 4) {
                            TextField("", text: $courseName)
                                .font(.headline)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)

                            Divider()
                                .frame(maxWidth: 350)
                        }
                    }

                    // MARK: - Course Code
                    VStack(alignment: .center, spacing: 6) {
                        Text("Course Code")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        VStack(spacing: 4) {
                            TextField("", text: $courseCode)
                                .font(.subheadline.bold())
                                .foregroundColor(.secondary)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
                                


                            Divider()
                                .frame(maxWidth: 350)
                        }
                    }
                    
                    // MARK: - Icon Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ICON")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        IconPickerGrid(selectedIcon: $courseIcon)
                    }
                    .padding(.top, 8)
                    
                    // MARK: - Color Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COLOR")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ColorPickerRow(selectedColor: $courseColor)
                    }
                    
                    Spacer()
                }
            }
            .background(AppColors.background)
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
                        dismiss()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}

// MARK: - Icon Picker Grid
struct IconPickerGrid: View {
    @Binding var selectedIcon: String

    // Pull icons from the single source of truth in Constants.swift
    let icons = AppIcons.courseIcons

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Horizontal scroll container
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [
                    GridItem(.fixed(40), spacing: 12),
                    GridItem(.fixed(40), spacing: 12),
                    GridItem(.fixed(40), spacing: 12)
                ], spacing: 12) {
                    ForEach(icons, id: \.self) { icon in
                        Button(action: {
                            selectedIcon = icon
                        }) {
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundColor(selectedIcon == icon ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(selectedIcon == icon ? AppColors.primary : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 148) // 3 rows × 40pt + spacing

            // Scroll hint
            Text("Swipe for more icons →")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
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
        .padding(.horizontal)
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

