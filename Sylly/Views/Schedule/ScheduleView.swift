//
//  ScheduleView.swift
//  Sylly
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    // MARK: - Database
    @Environment(\.modelContext) private var modelContext
    @Query private var assignments: [Assignment]
    @State private var selectedDate: Date = Date()
    // false = compact week strip, true = full month grid
    @State private var showMonth = false
    // Which month the grid is showing while browsing
    @State private var displayedMonth = Date()
    @Binding var navigationState: NavigationState

    // MARK: - Ask for Notification Permission
    // Anyone who updated to 1.0.5 already scanned before reminders existed, so they
    // never reach the ask in SuccessView. Catch them here, with their assignments
    // on screen behind the popup so the reason for it is obvious.
    private func askForNotificationsIfNeeded() async {
        // Nothing to remind about — a brand new user gets asked after their first scan
        if assignments.isEmpty {
            return
        }

        let status = await NotificationService.shared.currentStatus()

        // Already answered, one way or the other
        if status != .notDetermined {
            return
        }

        let granted = await NotificationService.shared.requestPermission()

        // Their existing assignments have no reminders yet — book them all now
        if granted {
            NotificationService.shared.refreshAll(context: modelContext)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if assignmentsForSelectedDate.isEmpty {
                        EmptyScheduleView(showMascot: !showMonth)
                    } else {
                        ForEach(assignmentsForSelectedDate) { assignment in
                            ScheduleCard(assignment: assignment, navigationState: $navigationState)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .background(AppColors.background)
            .navigationTitle("Calendar")
            // Only shows once the user moves off today. The button appearing is
            // itself the hint that they're looking at a week that isn't this one.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !Calendar.current.isDateInToday(selectedDate) {
                        Button("Today") {
                            withAnimation {
                                selectedDate = Date()
                                // Bring the grid back too, in case they browsed away
                                displayedMonth = Date()
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                // MARK: - Fixed Header
                // Week Strip Card background (white)
                VStack(spacing: 10){
                    // Five days by default, the whole month once expanded
                    if showMonth {
                        MonthGridView(
                            displayedMonth: $displayedMonth,
                            selectedDate: $selectedDate,
                            assignments: assignments
                        )
                    } else {
                        WeekStripView(selectedDate: $selectedDate)
                    }

                    // Selected Date Label — tap to switch between week and month
                    Button {
                        // Open on the month you're actually looking at — the arrows
                        // can leave displayedMonth somewhere else entirely
                        if !showMonth {
                            displayedMonth = selectedDate
                        }
                        withAnimation {
                            showMonth.toggle()
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                            Image(systemName: showMonth ? "chevron.up" : "chevron.down")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(AppColors.background)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .task {
                await askForNotificationsIfNeeded()
            }
        }
    }

    // MARK: - Computed Property: Assignments for Selected Date
    private var assignmentsForSelectedDate: [Assignment] {
        // Use Apple's Calendar tool to check if the assignment day matches the clicked day
        // Use 'isDate' because it ignores the Time (hours/mins) and only compares the Day
        assignments.filter { assignment in
            Calendar.current.isDate(assignment.dueDate, inSameDayAs: selectedDate)
        }
    }
}


// MARK: - Preview
#Preview {
    ScheduleView(navigationState: .constant(.home))
            // wrap it in a 'Data Provider' so the @Query doesn't crash
            // use 'inMemory' so the test data doesn't accidentally save to the actual app
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
