//
//  ScheduleCard.swift
//  Sylly
//

import SwiftUI

struct ScheduleCard: View {
    let assignment: Assignment
    @Binding var navigationState: NavigationState

    // MARK: - Body
    var body: some View {
        if let course = assignment.course {
            NavigationLink(destination: CourseDetailView(course: course, navigationState: $navigationState)) {
                cardContent
            }
        } else {
            cardContent
        }
    }

    // MARK: - Card Content
    private var cardContent: some View {
        HStack(spacing: 12) {

            // Course icon in colored box
            if let course = assignment.course {
                Image(systemName: course.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(AppColors.color(from: course.color))
                    .cornerRadius(10)
            }

            // Assignment info
            VStack(alignment: .leading, spacing: 4) {

                // Assignment title
                Text(assignment.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                // Course name
                if let course = assignment.course {
                    Text(course.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Due date & time
                Text("\(getDueDateLabel(from: assignment.dueDate)) at \(getTimeString(from: assignment.dueDate))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(urgencyColor(for: assignment))
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            // Chevron arrow
            Image(systemName: AppIcons.chevronRight)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }

    // MARK: - Helper: Get Due Date Label
    // Returns "Due Today", "Due Tomorrow", or "Due Feb 18" etc.
    private func getDueDateLabel(from date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Due Today"
        } else if Calendar.current.isDateInTomorrow(date) {
            return "Due Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // "Feb 18"
            return "Due \(formatter.string(from: date))"
        }
    }

    // MARK: - Helper: Urgency Color
    // Red for ≤2 days, yellow/orange for ≤7 days, gray/blue for further out
    private func urgencyColor(for assignment: Assignment) -> Color {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: calendar.startOfDay(for: assignment.dueDate)).day ?? 0

        if days <= 2 {
            return AppColors.urgent
        } else if days <= 7 {
            return AppColors.warning
        } else {
            return AppColors.neutral
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
    
    return ScheduleCard(assignment: assignment, navigationState: .constant(.home))
        .padding()
}
