//
//  MonthGrid.swift
//  Sylly
//
//  Date math for the month calendar. No UI in this file.
//

import Foundation

// Every date in the month that `date` falls in, in order.
func daysInMonth(for date: Date) -> [Date] {
    let calendar = Calendar.current

    // The 1st of whatever month `date` is in
    guard let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
        return []
    }

    // How many days this month has (28, 29, 30 or 31)
    guard let dayCount = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count else {
        return []
    }

    var days: [Date] = []
    for offset in 0..<dayCount {
        if let day = calendar.date(byAdding: .day, value: offset, to: firstOfMonth) {
            days.append(day)
        }
    }

    return days
}

// The same days, lined up for a 7-column grid.
// nil means an empty cell before the 1st.
func monthGridCells(for date: Date) -> [Date?] {
    let days = daysInMonth(for: date)
    guard let firstDay = days.first else {
        return []
    }

    var cells: [Date?] = []

    // weekday is 1 for Sunday, 2 for Monday and so on, so subtracting 1
    // gives how many blank cells sit before the 1st.
    let blanksBefore = Calendar.current.component(.weekday, from: firstDay) - 1
    for _ in 0..<blanksBefore {
        cells.append(nil)
    }

    for day in days {
        cells.append(day)
    }

    return cells
}
