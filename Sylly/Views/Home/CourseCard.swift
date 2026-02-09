//
//  CourseCard.swift
//  Sylly
//
//

import SwiftUI

struct CourseCard: View {

    let course: Course

    // MARK: - Helper: Color from String
    private func colorFromString(_ colorName: String) -> Color {
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
        default: return Color("BrandPrimary")
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            
            // Course icon in colored container
            Image(systemName: course.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(colorFromString(course.color))
                .cornerRadius(10)
            
            // Course info
            VStack(alignment: .leading, spacing: 4) {
                Text(course.code)
                    .font(.caption)
                    .foregroundColor(AppColors.primary)
                
                Text(course.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // Next assignment info, this checks if there is an upcoming assignment to show
                if let nextAssignment = getNextAssignment() {
                    HStack (spacing: 4) {
                        Text("Next: \(nextAssignment.title)")
                        Text("•")
                        Text(dueText(for: nextAssignment))
                            .foregroundColor(urgencyColor(for: nextAssignment))
                            .fontWeight(.bold)
                            
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } else {
                    Text("No upcoming assignments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        
                    }
                    
            }
            Spacer() // Pushing everything of the course content to the left side and making the chevron right symbol to the right side of the card
            
            Image(systemName: AppIcons.chevronRight)
                .foregroundColor(.gray)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)

    }

    // MARK: - Helper: Next Assignment
    private func getNextAssignment() -> Assignment? {
        let upcoming = course.assignments
            // Filter: Only show assignments that aren't completed
            // (!$0 means "this assignment is NOT done")
            .filter { !$0.isCompleted }
            // Sort: Put the assignments in order by date (soonest first)
            .sorted { $0.dueDate < $1.dueDate }
        // Picking the very first assignment from the sorted list
        return upcoming.first
    }

    // MARK: - Helper: Due Text
    private func dueText(for assignment: Assignment) -> String {
        // Count how many days are between 'Right Now' and the 'Due Date'
        let days = Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0

        // For close assignments, show relative time
        if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "in 1 day"
        } else if days > 1 && days < 7 {
            return "in \(days) days"
        } else if days >= 7 && days < 14 {
            return "in 1 week"
        } else if days >= 14 && days < 105 { // ~15 weeks: show relative time
            return "in \(days / 7) weeks"
        } else {
            // For far away assignments or past due, just show the date
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: assignment.dueDate)
        }
    }

    // MARK: - Helper: Urgency Color
    private func urgencyColor(for assignment: Assignment) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0

        // Pick a color based on that number
        if days < 0 {
            // Past due. Use the 'Neutral' color (Gray/Blue)
            return AppColors.neutral
        } else if days <= 2 {
            // Very close! Use the 'Urgent' color (Red)
            return AppColors.urgent
        } else if days <= 7 {
            // Coming up soon. Use the 'Warning' color (Yellow/Orange)
            return AppColors.warning
        } else {
            // Far away. Use the 'Neutral' color (Gray/Blue)
            return AppColors.neutral
        }
    }
    }

// MARK: - Preview
#Preview {

    // Mock data to view the preview window screen
    let course = Course(
        name: "Intro to AI",
        code: "CAP 4630",
        icon: "brain.head.profile",
        color: "BrandPrimary"
    )
    
    // show the CourseCard using that fake data
    return CourseCard(course: course)
        .padding() // Add space around the card so it's easy to see
}
