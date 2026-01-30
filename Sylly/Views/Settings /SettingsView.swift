//
//  SettingsView.swift
//  Sylly
//
//



import SwiftUI
import SwiftData

struct SettingsView: View {

    // MARK: - Database Access
    // Access the database so we can delete data
    // Enviornment - property wrapper that acccess shared values from app's enviornment
    // modelContext is SwiftData's database manager for saving, deleting, fetching/querying data from database
    @Environment(\.modelContext) private var modelContext
    @Query private var courses: [Course]

    // MARK: - State Properties
    // State for alerts
    @State private var showDeleteAlert = false

    // MARK: - AppStorage: Persistent User Settings
    // @AppStorage automatically saves/loads values to device storage (UserDefaults)
    // "selectedCalendar" is the key name for storing this value persistently
    // When user picks a calendar, it saves automatically and syncs with CalendarPickerView
    @AppStorage("selectedCalendar") private var selectedCalendar = "School"

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // List displays items in a scrollable list format
            List {

                // MARK: - PREFERENCES Section
                Section(header: Text("PREFERENCES")) {

                    // Calendar picker with navigation
                    NavigationLink(destination: CalendarPickerView()) {
                        HStack {
                            SettingsIcon(icon: "calendar", color: .blue)
                            Text("Calendar")
                            Spacer()
                            Text(selectedCalendar)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // MARK: - SUPPORT Section
                Section(header: Text("SUPPORT")) {

                    // Rate Sylly button - opens App Store
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
            Text("Sylly v1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
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
    }

    // MARK: - Helper: Open App Store
    // Open App Store (replace app link later)
    private func openAppStore() {
        // Will replace this with my actual link later
        if let url = URL(string: "https://apps.apple.com/app/idYOURAPPID") {
            // UIApplication is main IOS app object and controls everything in this app
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helper: Open Email
    // Open email for feedback
    private func openEmail() {
        // Replace with my email later 
        if let url = URL(string: "mailto:your.email@example.com?subject=Sylly%20Feedback") {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helper: Open Privacy Policy
    // Open Privacy Policy webpage
    private func openPrivacyPolicy() {
        // Replace with privacy policy URL later
        if let url = URL(string: "https://yourwebsite.com/privacy") {
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
            .font(.body)
            .foregroundColor(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .cornerRadius(6)
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
