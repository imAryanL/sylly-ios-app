//
//  CalendarPickerView.swift
//  Sylly
//
//  This view used to show a fake list of calendars, but since
//  EventKit (Apple's calendar framework) isn't built yet,
//  Replaced it with a "coming soon" placeholder
//  Once we build calendar export, I will replace this with real calendars
//

import SwiftUI

struct CalendarPickerView: View {

    // MARK: - Body
    var body: some View {

        // VStack stacks everything vertically with 20pt spacing between items
        VStack(spacing: 20) {

            // Pushes content to the center of the screen
            Spacer()

            // A calendar icon to visually communicate what this feature is about
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))

            // Feature title
            Text("Calendar Export")
                .font(.title2)
                .fontWeight(.bold)

            // Short explanation so the user knows this isn't broken, just not ready yet
            Text("Automatically add assignments to your Apple Calendar. This feature is coming soon!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)  // Centers text when it wraps to multiple lines
                .padding(.horizontal, 40)          // Adds side padding so text doesn't touch screen edges

            // Pushes content to the center (Spacer top + Spacer bottom = centered)
            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CalendarPickerView()
    }
}
