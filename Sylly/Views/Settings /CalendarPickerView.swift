//
//  CalendarPickerView.swift
//  Sylly
//

import SwiftUI

struct CalendarPickerView: View {

    // MARK: - AppStorage: Persistent User Settings
    // @AppStorage with the same key name ("selectedCalendar") connects to SettingsView
    // Both views read/write to the same device storage location automatically
    // When user selects a calendar here, it updates immediately in SettingsView too
    @AppStorage("selectedCalendar") private var selectedCalendar = "School"
    @Environment(\.dismiss) private var dismiss


    // MARK: - Data
    // List of calendar options user can choose from
    let calendars = ["School", "Personal", "Work", "Family"]

    // MARK: - Body
    var body: some View {
        List {
            // Loop through each calendar option
            // id: \.self tells SwiftUI to use the string itself as the unique identifier
            ForEach(calendars, id: \.self) { calendar in
                Button(action: {
                    // When user taps a calendar, update the parent's selectedCalendar value
                    selectedCalendar = calendar
                    // Close this view and return to Settings
                    dismiss()
                }) {
                    HStack {
                        Text(calendar)
                            .foregroundColor(.primary)

                        Spacer()

                        // MARK: - Checkmark Indicator
                        // Show a checkmark next to the currently selected calendar
                        if calendar == selectedCalendar {
                            Image(systemName: "checkmark")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CalendarPickerView()
    }
}
