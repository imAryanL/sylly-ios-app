//
//  AssignmentDetailRow.swift
//  Sylly
//
//

import SwiftUI

struct AssignmentDetailRow: View {
    let assignment: Assignment
    let isCompleted: Bool  // Whether this assignment is done or not
    let onTap: () -> Void  // Callback when row is tapped
    
    var body: some View {
        // Arrange items horizontally with 12pt space between them
        HStack(spacing: 12) {
            
            // MARK: - Completion Indicator Circle
            // Shows different icon based on completion status
            if isCompleted {
                // If assignment is completed, show a green checkmark in a circle
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green) 
                    .font(.title3)  
            } else {
                // If assignment is upcoming, show a blue filled circle
                Image(systemName: "circle.fill")
                    .foregroundColor(AppColors.primary)  
                    .font(.title3)  
            }
            
            // MARK: - Assignment Information Section
            // Vertical stack for title and metadata
            VStack(alignment: .leading, spacing: 2) {  
                // Assignment title 
                Text(assignment.title)
                    .font(.body)  
                    // If completed, make text gray (lighter). If upcoming, make text dark (heavier)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                
                // Date and assignment type 
                // Example: "Feb 12 • Exam"
                Text("\(getDateString()) • \(assignment.type.capitalized)")
                    .font(.caption)  
                    .foregroundColor(.secondary)  
            }
            
            // MARK: - Spacer (Pushes Next Item to Right)
            // This pushes the chevron arrow all the way to the right side
            Spacer()
            
            // MARK: - Chevron Arrow (Indicates Tappable)
            // Right-pointing arrow that suggests this row can be tapped for more details
            Image(systemName: AppIcons.chevronRight)
                .foregroundColor(.gray)  
                .font(.caption)  
        }
        .padding()
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Date Formatting Helper
    // Converts the full date into a readable format like "Feb 12"
    private func getDateString() -> String {
        // Create a DateFormatter (tool for converting dates to strings)
        let formatter = DateFormatter()
        
        // Set the format: "MMM d" means "Month (3 letters) + Day"
        // Examples: "Feb 12", "Jan 5", "Dec 25"
        formatter.dateFormat = "MMM d"
        
        // Convert the assignment's due date to a string using the formatter
        return formatter.string(from: assignment.dueDate)
    }
}

#Preview {
    // Show two example rows for testing: one completed, one upcoming
    VStack {
        // Example 1: Upcoming assignment
        AssignmentDetailRow(
            assignment: Assignment(title: "Midterm Exam", dueDate: Date(), type: "exam"),
            isCompleted: false,
            onTap: { }
        )

        // Visual divider between rows
        Divider()

        // Example 2: Completed assignment
        AssignmentDetailRow(
            assignment: Assignment(title: "Quiz 1", dueDate: Date(), type: "quiz"),
            isCompleted: true,
            onTap: { }
        )
    }
    .background(Color.white)
}
