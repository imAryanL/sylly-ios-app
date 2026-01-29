//
//  ScheduleCard.swift
//  Sylly
//

import SwiftUI

struct ScheduleCard: View {
    let assignment: Assignment

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            
            // Course icon in colored box
            if let course = assignment.course {
                Image(systemName: course.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(getColor(from: course.color))
                    .cornerRadius(10)
            }
            
            // Assignment info
            VStack(alignment: .leading, spacing: 4) {
                
                // Assignment title
                Text(assignment.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Course name
                if let course = assignment.course {
                    Text(course.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Due time
                Text("Due Today at \(getTimeString(from: assignment.dueDate))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.urgent)
            }
            
            Spacer()
            
            // Chevron arrow
            Image(systemName: AppIcons.chevronRight)
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    // MARK: - Helper: Get Color
    private func getColor(from colorName: String) -> Color {
        switch colorName.lowercased() {
        case "brandprimary": return Color("BrandPrimary")
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        case "blue": return .blue
        case "pink": return .pink
        case "purple": return .purple
        case "black": return .black
        case "gray": return .gray
        default: return Color("BrandPrimary") // Fallback color if something goes wrong
        }
    }

    // MARK: - Helper: Get Time String
    private func getTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"  // "2:00 PM" // Tells Swift: "Give me '2:00 PM' format"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    // Create fake course
    let course = Course(
        name: "Intro to Artificial Intelligence",
        code: "CAP 4630",
        icon: "brain.head.profile",
        color: "brandprimary"
    )
    
    // Create fake assignment
    let assignment = Assignment(
        title: "Midterm Exam",
        dueDate: Date(),
        type: "exam"
    )
    assignment.course = course
    
    return ScheduleCard(assignment: assignment)
        .padding()
}
