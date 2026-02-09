//
//  WeekStripView.swift
//  Sylly
//

import SwiftUI

struct WeekStripView: View {
    @Binding var selectedDate: Date

    // MARK: - Body
    var body: some View {
        HStack(spacing: 0) {
            // THE LOOP: Runs getWeekDates() to get a list of 5 dates,
            // then creates a 'DayButton' for each one in that list.
            ForEach(getWeekDates(), id: \.self) { date in
                DayButton(
                    date: date,
                    // Check if 'this' button matches the currently selected date to highlight it.
                    isSelected: isSameDay(date1: date, date2: selectedDate),
                    // ACTION: When tapped, tell the parent to update its date to 'this' one.
                    onTap: { selectedDate = date }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Helper: Week Dates
    private func getWeekDates() -> [Date] {
        let today = Date()
        
        // Walk backward and forward from today using Apple's Calendar math.
            let day1 = Calendar.current.date(byAdding: .day, value: -2, to: today)! // 2 days ago
            let day2 = Calendar.current.date(byAdding: .day, value: -1, to: today)! // Yesterday
            let day3 = today                                                       // Today
            let day4 = Calendar.current.date(byAdding: .day, value: 1, to: today)!  // Tomorrow
            let day5 = Calendar.current.date(byAdding: .day, value: 2, to: today)!  // Day after tomorrow
            
            return [day1, day2, day3, day4, day5]
        }

    // MARK: - Helper: Same Day Check
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

// MARK: - Day Button
struct DayButton: View {
    let date: Date
    let isSelected: Bool     // True if the circle should be blue
    let onTap: () -> Void    // The function to run when clicked
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Day name (MON, TUE, etc.)
                Text(dayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                
                // Day number (12, 13, 14, etc.)
                Text(dayNumber)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Circle()
                    .fill(isSelected ? AppColors.primary : Color.clear)
            )
        }
    }
    
    // Get day name like "MON"
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // "Mon", "Tue", etc.
        return formatter.string(from: date).uppercased()
    }
    
    // Get day number like "14"
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"  // "12", "13", "14", etc.
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    WeekStripView(selectedDate: .constant(Date()))
}
