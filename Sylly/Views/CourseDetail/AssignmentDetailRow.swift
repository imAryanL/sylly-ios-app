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
        // Top aligned, so the icon stays with the title when it wraps to several lines.
        HStack(alignment: .top, spacing: 12) {
            
            // MARK: - Completion Indicator
            // Same tile in both states, so only the colour and glyph change.
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
                    .frame(width: 36, height: 36)
                    .background(Color.green.opacity(0.15))
                    .cornerRadius(10)
            } else {
                Image(systemName: typeIcon())
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 36, height: 36)
                    .background(AppColors.primary.opacity(0.15))
                    .cornerRadius(10)
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
                // Matches the icon tile, so both sit level with the first line of the title.
                .frame(height: 36)
        }
        .padding()
        .onTapGesture {
            onTap()
        }
    }
    
    // MARK: - Type Icon
    // Four distinct shapes, so the type reads without looking at the text.
    private func typeIcon() -> String {
        switch assignment.type.lowercased() {
        case "exam": return "doc.text.fill"
        case "quiz": return "checklist"
        case "homework": return "books.vertical.fill"
        case "project": return "square.stack.3d.up.fill"
        default: return "doc.fill"
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
    .background(Color(UIColor.secondarySystemBackground))
}
