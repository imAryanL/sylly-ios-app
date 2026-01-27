//
//  CourseCard.swift
//  Sylly
//
//

import SwiftUI

struct CourseCard: View {
    
    let course: Course
    
    var body: some View {
        HStack(spacing: 12) {
            
            // Course icon in colored container
            Image(systemName: course.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color(course.color))
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
    
    // This function finds the one assignment you should work on next
    private func getNextAssignment() -> Assignment? {
        let upcoming = course.assignments
            // Filter: Throw away tasks that are finished or past due
            // (!$0 means "this assignment is NOT done")
            .filter { !$0.isCompleted && $0.dueDate > Date() }
            // Sort: Put the assignments in order by date (soonest first)
            .sorted { $0.dueDate < $1.dueDate }
        // Picking the very first assignment from the sorted list
        return upcoming.first
    }
    
    // This turns a date into a simple sentence like "in 3 days"
    private func dueText(for assignment: Assignment) -> String {
        // Count how many days are between 'Right Now' and the 'Due Date'
        let days = Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
        
        // Choosing the best words based on the number of the due date
        if days == 0 {
                    return "Due today" // 0 days left
                } else if days == 1 {
                    return "in 1 day"  // 1 day left
                } else if days < 7 {
                    return "in \(days) days" // 2 to 6 days left
                } else if days < 14 {
                    return "in 1 week" // 7 to 13 days left
                } else {
                    // Divide days by 7 to get the number of weeks
                    return "in \(days / 7) weeks"
                }
    }
    
    // This chooses a color based on how close the deadline is
    private func urgencyColor(for assignment: Assignment) -> Color {
    let days = Calendar.current.dateComponents([.day], from: Date(), to: assignment.dueDate).day ?? 0
        
        // Pick a color based on that number
        if days <= 2 {
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
