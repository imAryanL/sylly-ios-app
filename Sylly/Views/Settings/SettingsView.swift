//
//  SettingsView.swift
//  Sylly
//
//



import SwiftUI
import SwiftData
import EventKit

struct SettingsView: View {

    // MARK: - Database Access
    // Access the database so I can delete data
    // Enviornment - property wrapper that acccess shared values from app's enviornment
    // modelContext is SwiftData's database manager for saving, deleting, fetching/querying data from database
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]

    // MARK: - State Properties
    // State for alerts
    @State private var showDeleteAlert = false
    @State private var showAboutSheet = false


    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // List displays items in a scrollable list format
            List {

                // MARK: - PREFERENCES Section
                Section(header: Text("PREFERENCES")) {

                    // Calendar export — shows current permission status
                    NavigationLink(destination: CalendarPickerView()) {
                        HStack {
                            SettingsIcon(icon: "calendar", color: .blue)
                            Text("Calendar")
                            Spacer()
                            Text(CalendarService.shared.isAuthorized ? "Enabled" : "Off")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Due date reminders. iOS already owns the on/off switch for
                    // these, so this just takes the user there rather than keeping
                    // a second switch that could disagree with it.
                    Button {
                        Task {
                            await openRemindersSetting()
                        }
                    } label: {
                        HStack {
                            SettingsIcon(icon: "bell.fill", color: .red)
                            Text("Reminders")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("iOS Settings")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }

                // MARK: - SUPPORT Section
                Section(header: Text("SUPPORT")) {

                    // Rate Sylly button - only visible once the app is on the App Store
                    if AppConfig.isOnAppStore {
                        Button(action: openAppStore) {
                            HStack {
                                SettingsIcon(icon: "star.fill", color: .yellow)
                                Text("Rate Sylly")
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }

                    // Help & Feedback button - opens email
                    Button(action: openEmail) {
                        HStack {
                            SettingsIcon(icon: "questionmark", color: .green)
                            Text("Help & Feedback")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }

                    // Privacy Policy button - opens webpage
                    Button(action: openPrivacyPolicy) {
                        HStack {
                            SettingsIcon(icon: "lock.fill", color: .purple)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }

                // MARK: - ABOUT Section
                Section(header: Text("ABOUT")) {
                    Button(action: {
                        showAboutSheet = true
                    }) {
                        HStack {
                            SettingsIcon(icon: "info.circle.fill", color: .indigo)
                            Text("About Sylly")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }

                // MARK: - DANGER ZONE Section
                // Destructive actions (delete all data)
                Section(header: Text("DANGER ZONE")) {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            SettingsIcon(icon: "trash.fill", color: .gray)
                            Text("Delete all data")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            
            // MARK: - Footer Section
            // Spacer pushes footer to the bottom of the screen
            Spacer()
            
            // App version footer (outside List so it stays at bottom)
            Text("Sylly v\(AppConfig.version)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        // About sheet
        .sheet(isPresented: $showAboutSheet) {
            AboutView()
        }
        // Delete confirmation alert - prevents accidental data loss
        .alert("Delete All Data?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("This will permanently delete all your courses and assignments. This cannot be undone.")
        }
    }

    // MARK: - Helper: Delete All Data
    // Delete all courses (assignments delete automatically because of .cascade relationship)
    private func deleteAllData() {
        for course in courses {
            modelContext.delete(course)
        }

        // delete() only marks them in memory — nothing leaves the database until
        // save(), and the reminders shouldn't go until the data actually has
        do {
            try modelContext.save()
            NotificationService.shared.cancelAll()
        } catch {
            modelContext.rollback()
            print("Error deleting all data: \(error)")
        }
    }

    // MARK: - Helper: Open App Store
    // Opens Sylly's App Store page so users can leave a rating
    private func openAppStore() {
        if let url = URL(string: "https://apps.apple.com/app/id6759631749") {
            // UIApplication is main IOS app object and controls everything in this app
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helper: Reminders Row
    // If they have never been asked, ask here. iOS shows no Notifications section
    // for an app that has never requested, so sending them to Settings first is
    // a dead end.
    private func openRemindersSetting() async {
        let status = await NotificationService.shared.currentStatus()

        if status == .notDetermined {
            let granted = await NotificationService.shared.requestPermission()

            // Nothing has reminders yet — book them all now
            if granted {
                NotificationService.shared.refreshAll(context: modelContext)
            }
            return
        }

        openIOSSettings()
    }

    // MARK: - Helper: Open iOS Settings
    // Send them to Sylly's page in the iOS Settings app
    private func openIOSSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // Open email for feedback
    private func openEmail() {
        if let url = URL(string: "mailto:sylly.feedback@gmail.com?subject=Sylly%20Feedback") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helper: Open Privacy Policy
    // Open Privacy Policy webpage
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://imaryanl.github.io/sylly-privacy") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Settings Icon Component
// Reusable icon component: colored background with white icon
struct SettingsIcon: View {
    let icon: String
    let color: Color

    // MARK: - Body
    var body: some View {
        Image(systemName: icon)
            .font(.body.weight(.medium))
            .foregroundColor(.white)
            .frame(width: 32, height: 32)
            .background(color)
            .cornerRadius(7)
    }
}

// MARK: - Preview
#Preview {
    // NavigationStack is required because SettingsView uses .navigationTitle() and .navigationBarTitleDisplayMode()
    NavigationStack {
        SettingsView()
            // Set up a temporary in-memory database for preview (doesn't affect real data)
            // Includes Course and Assignment data models needed by @Query and @Environment
            .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
    }
}
