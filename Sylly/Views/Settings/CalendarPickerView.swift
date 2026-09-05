//
//  CalendarPickerView.swift
//  Sylly
//
//  Shows the current calendar permission status and explains
//  how calendar export works in Sylly.
//

import SwiftUI
import EventKit

struct CalendarPickerView: View {

    // MARK: - Properties
    // Tracks whether the user has granted calendar permission
    // Read from CalendarService which uses EventKit under the hood
    @State private var isAuthorized: Bool = CalendarService.shared.isAuthorized

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            // MARK: - Status Icon
            // Shows a checkmark calendar when enabled, regular calendar when not
            Image(systemName: isAuthorized ? "calendar.badge.checkmark" : "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(isAuthorized ? .green : .secondary.opacity(0.5))

            // MARK: - Status Title
            Text(isAuthorized ? "Calendar Connected" : "Calendar Not Connected")
                .font(.title2)
                .fontWeight(.bold)

            // MARK: - Description
            // Explains how calendar export works in the app
            if isAuthorized {
                Text("Sylly can add your assignment due dates to Apple Calendar. You'll see the option after scanning a syllabus.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // Let users manage (or disable) calendar access in iOS Settings
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Manage in Settings")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary.opacity(0.14))
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 40)
            } else {
                Text("Enable calendar access so Sylly can add your assignment due dates to Apple Calendar. You'll see the option after scanning a syllabus.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                // MARK: - Open Settings Button
                // Takes the user to iOS Settings → Sylly → Calendars
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Same treatment as the scan button on Home.
                        .background(
                            ZStack {
                                AppColors.primary
                                LinearGradient(
                                    stops: [
                                        .init(color: Color.white.opacity(0.14), location: 0.0),
                                        .init(color: Color.clear, location: 0.75),
                                        .init(color: Color.black.opacity(0.12), location: 1.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            }
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 40)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isAuthorized = CalendarService.shared.isAuthorized
        }
        // onAppear alone misses the trip to iOS Settings — the view never leaves
        // the hierarchy, so coming back to the app has to refresh it too.
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                isAuthorized = CalendarService.shared.isAuthorized
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        CalendarPickerView()
    }
}
