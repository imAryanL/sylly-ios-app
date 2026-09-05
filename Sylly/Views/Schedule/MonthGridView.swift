//
//  MonthGridView.swift
//  Sylly
//
//  Draws one month as a 7-column calendar. Tapping a day sets selectedDate.
//

import SwiftUI

struct MonthGridView: View {
    // Which month the grid is showing. Separate from selectedDate so the user
    // can browse ahead without changing the day they picked.
    @Binding var displayedMonth: Date

    // The day the user has picked. Same binding WeekStripView uses.
    @Binding var selectedDate: Date

    // Everything due, so the grid can work out which days get dots
    let assignments: [Assignment]

    // Seven equal-width columns, one per weekday
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private let weekdayNames = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 8) {
            // Month name with arrows to step back and forward
            HStack {
                Button {
                    changeMonth(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                }

                Spacer()

                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    changeMonth(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, 8)

            // Weekday header
            HStack(spacing: 0) {
                ForEach(weekdayNames.indices, id: \.self) { index in
                    Text(weekdayNames[index])
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // The days themselves
            LazyVGrid(columns: columns, spacing: 8) {
                // Index-based because the blanks are nil and would collide as IDs
                ForEach(monthCells.indices, id: \.self) { index in
                    if let day = monthCells[index] {
                        Button {
                            selectedDate = day
                        } label: {
                            VStack(spacing: 3) {
                                Text("\(Calendar.current.component(.day, from: day))")
                                    .font(.body)
                                    .foregroundColor(isSelected(day) ? .white : .primary)
                                    .frame(maxWidth: .infinity, minHeight: 36)
                                    .background(
                                        Circle()
                                            .fill(isSelected(day) ? AppColors.primary : Color.clear)
                                    )

                                dotRow(for: day)
                            }
                        }
                    } else {
                        // Blank cell. Matches a real cell's height so rows stay level.
                        VStack(spacing: 3) {
                            Text("")
                                .frame(maxWidth: .infinity, minHeight: 36)
                            Color.clear.frame(height: 5)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    // Worked out once instead of on every row
    private var monthCells: [Date?] {
        monthGridCells(for: displayedMonth)
    }

    // Step the grid forward or back a month
    private func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    // The dots under one day. Always 5pt tall, even with no dots, so days
    // with work don't sit lower than days without and skew the row.
    private func dotRow(for day: Date) -> some View {
        let colors = dotColors(for: day)

        return HStack(spacing: 3) {
            ForEach(colors.indices, id: \.self) { index in
                Circle()
                    .fill(colors[index])
                    .frame(width: 5, height: 5)
            }
        }
        .frame(height: 5)
    }

    // Compares by day only, ignoring the time of day
    private func isSelected(_ day: Date) -> Bool {
        Calendar.current.isDate(day, inSameDayAs: selectedDate)
    }

    // One dot per COURSE that has something due that day, in the course's colour.
    // Three Bio assignments on one day draw a single green dot, not three.
    // Stops at three courses — more than that on one cell is unreadable.
    private func dotColors(for day: Date) -> [Color] {
        var colors: [Color] = []
        var seenCourses: [UUID] = []

        for assignment in assignments {
            if Calendar.current.isDate(assignment.dueDate, inSameDayAs: day) {
                if let course = assignment.course {
                    if !seenCourses.contains(course.id) {
                        seenCourses.append(course.id)
                        colors.append(AppColors.color(from: course.color))
                    }
                } else {
                    colors.append(AppColors.primary)
                }
            }

            if colors.count == 3 {
                break
            }
        }

        return colors
    }
}

// MARK: - Preview
// @Previewable gives the preview real state, so taps actually move the selection.
// Fixed to September 2026 so the sample dates always land inside the month shown.
#Preview {
    @Previewable @State var selected = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1)) ?? Date()
    @Previewable @State var shownMonth = Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 1)) ?? Date()

    MonthGridView(
        displayedMonth: $shownMonth,
        selectedDate: $selected,
        assignments: [
            Assignment(title: "Midterm Exam",
                       dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 10)) ?? Date(),
                       type: "exam"),
            Assignment(title: "Essay Draft",
                       dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 17)) ?? Date(),
                       type: "homework"),
            Assignment(title: "Quiz 2",
                       dueDate: Calendar.current.date(from: DateComponents(year: 2026, month: 9, day: 17)) ?? Date(),
                       type: "quiz")
        ]
    )
}
