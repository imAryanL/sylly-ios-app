//
//  ScheduleView.swift
//  Sylly
//

import SwiftUI
import SwiftData

struct ScheduleView: View {
    @Query private var assignments: [Assignment]
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                
                // Week Strip Card background (white)
                VStack(spacing: 10){
                // Week Strip, when clicking a day in this sub-view, it updates the state here
                WeekStripView(selectedDate: $selectedDate)
                
                    // Selected Date Label
                    Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Content
                if assignmentsForSelectedDate.isEmpty {
                    EmptyScheduleView()
                } else {
                    FilledScheduleView(assignments: assignmentsForSelectedDate)
                }
            }
            .background(AppColors.background)
            .navigationTitle("Schedule")
        }
    }
    
    // Filter assignments for the selected date
    private var assignmentsForSelectedDate: [Assignment] {
        // Use Apple's Calendar tool to check if the assignment day matches the clicked day
        // We use 'isDate' because it ignores the Time (hours/mins) and only compares the Day
        assignments.filter { assignment in
            Calendar.current.isDate(assignment.dueDate, inSameDayAs: selectedDate)
        }
    }
}

// MARK: - Filled Schedule View
struct FilledScheduleView: View {
    let assignments: [Assignment]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // This loops through filtered list and creates a UI card for each one
                ForEach(assignments) { assignment in
                    // pass the specific assignment data into the 'ScheduleCard' component
                    ScheduleCard(assignment: assignment)
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    ScheduleView()
            // wrap it in a 'Data Provider' so the @Query doesn't crash
            // use 'inMemory' so the test data doesn't accidentally save to the actual app
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
