//
//  CourseCard.swift
//  Sylly
//
//

import SwiftUI

struct CourseCard: View {

    let course: Course

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            
            // Course icon in colored container
            Image(systemName: course.icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(AppColors.color(from: course.color))
                .cornerRadius(12)
            
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
                    // Assignment name on first line
                    Text("Next: \(nextAssignment.title)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    // Urgency text on second line (more visible this way)
                    Text(dueText(for: nextAssignment))
                        .font(.caption)
                        .foregroundColor(urgencyColor(for: nextAssignment))
                        .fontWeight(.bold)
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
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)

    }

    // MARK: - Helper: Next Assignment
    private func getNextAssignment() -> Assignment? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())  // Get today's date at midnight

        let upcoming = course.assignments
            // Filter: Only show incomplete assignments that are due in the future (not overdue)
            .filter { !$0.isCompleted && calendar.startOfDay(for: $0.dueDate) >= today }
            // Sort: Put the assignments in order by date (soonest first)
            .sorted { $0.dueDate < $1.dueDate }
        // Picking the very first upcoming assignment from the sorted list
        return upcoming.first
    }

    // MARK: - Helper: Due Text
    private func dueText(for assignment: Assignment) -> String {
        let calendar = Calendar.current

        // IMPORTANT: Always use startOfDay() when comparing dates!
        // Without it, time components affect the day count.
        // Example: If today is Feb 11 at 5:00 PM and due date is Feb 13 at midnight,
        // the difference might be 1.7 days, which rounds down to 1 instead of 2.
        // startOfDay() sets both to 00:00:00, giving a pure day count (2 days).
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: assignment.dueDate)).day ?? 0

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
        // Strip time components for accurate day count (same pattern as dueText)
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: assignment.dueDate)).day ?? 0

        // Pick a color based on that number
        if days <= 2 {
            // Close date compared to current date. Use the 'Urgent' color (Red)
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
