//
//  SuccessView.swift
//  Sylly
//
//  This view shows after successfully saving assignments.
//  Users can export their assignments to Apple Calendar from here.
//  It also asks for an App Store review once the user has saved a couple of times.
//

import SwiftUI
import SwiftData
import StoreKit
import UserNotifications

struct SuccessView: View {

    // MARK: - Properties
    let assignmentCount: Int
    let course: Course  // The saved Course with all its assignments (for calendar export)

    // MARK: - Navigation
    @Binding var navigationState: NavigationState
    @Binding var selectedTab: Int

    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    // Apple's built-in way to ask for an App Store review
    @Environment(\.requestReview) private var requestReview

    // MARK: - Saved to the Device
    // Counts how many syllabi the user has saved, in total, ever.
    // @AppStorage saves this on the phone, so it survives closing the app.
    @AppStorage("successfulSaveCount") private var successfulSaveCount = 0

    // MARK: - State Properties
    // Tracks the "Add to Calendar" button state (idle → loading → done)
    @State private var calendarState: CalendarButtonState = .idle
    // Controls the "permission denied" alert
    @State private var showPermissionDeniedAlert = false
    // Controls the "some events failed" alert
    @State private var showPartialFailureAlert = false
    // Names of assignments that failed to export
    @State private var failedExportTitles: [String] = []
    // Controls the "something went wrong" error alert
    @State private var showCalendarErrorAlert = false

    // "1 assignment ... has" reads wrong in the plural, so the two are written out.
    private var subtitle: String {
        if assignmentCount == 1 {
            return "1 assignment from \(course.name) has been saved to Sylly."
        }
        return "\(assignmentCount) assignments from \(course.name) have been saved to Sylly."
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Course Icon
            // The course they just added, not a generic tick.
            ZStack(alignment: .bottomTrailing) {
                Image(systemName: course.icon)
                    .font(.system(size: 52))
                    .foregroundColor(.white)
                    .frame(width: 116, height: 116)
                    .background(
                        ZStack {
                            AppColors.color(from: course.color)
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.22), location: 0.0),
                                    .init(color: Color.clear, location: 0.7),
                                    .init(color: Color.black.opacity(0.12), location: 1.0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                    )
                    .cornerRadius(26)

                ZStack {
                    // Ring in the page colour, so the badge reads off the tile.
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 44, height: 44)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(.white, Color.green)
                }
                .offset(x: 10, y: 10)
            }
            // offset does not grow the frame, so the badge would sit in the stack's spacing.
            .padding(.bottom, 10)

            // MARK: - Title
            Text("You're all set!")
                .font(.title)
                .fontWeight(.bold)

            // MARK: - Subtitle
            // Says "saved to Sylly" because calendar export is a separate step below
            Text(subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            // MARK: - Add to Calendar Button
            // Green button with 3 states: idle, loading, done
            Button(action: {
                addToCalendar()
            }) {
                HStack(spacing: 8) {
                    // Icon changes based on state
                    if calendarState == .loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else if calendarState == .done {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "calendar.badge.plus")
                            .foregroundColor(.white)
                    }

                    Text(calendarState.label)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                // Same treatment as the scan button on Home.
                .background(
                    ZStack {
                        calendarState.buttonColor
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
            .disabled(calendarState == .loading || calendarState == .done)
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal)

            // MARK: - View Calendar Button
            Button(action: {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                selectedTab = 2
                navigationState = .home
            }) {
                Text("View Calendar")
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary.opacity(0.14))
                    .clipShape(Capsule())
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.horizontal)

            // MARK: - Back to Home Button
            Button(action: {
                selectedTab = 0
                navigationState = .home
            }) {
                Text("Back to home")
                    .foregroundColor(AppColors.primary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))

        // MARK: - Ask for a Review
        // .task runs when this screen appears, and cancels itself if the user leaves
        .task {
            await askForNotificationsIfNeeded()
            await askForReviewIfReady()
        }

        // MARK: - Permission Denied Alert
        .alert("Calendar Access Required", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Sylly needs calendar access to add your assignments. Please enable it in Settings > Sylly > Calendars.")
        }

        // MARK: - Calendar Error Alert
        .alert("Something Went Wrong", isPresented: $showCalendarErrorAlert) {
            Button("Try Again", role: .cancel) { }
        } message: {
            Text("Couldn't access your calendar. Please try again.")
        }

        // MARK: - Partial Failure Alert
        .alert("Some Assignments Weren't Added", isPresented: $showPartialFailureAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            let names = failedExportTitles.joined(separator: ", ")
            Text("These assignments couldn't be added to your calendar:\n\n\(names)")
        }
    }

    // MARK: - Ask for Notification Permission
    // Asked on the first save, when the point of reminders is obvious.
    // iOS only shows this popup once ever — if the user says no, the only way
    // back is the iOS Settings app, so the moment matters.
    private func askForNotificationsIfNeeded() async {
        let status = await NotificationService.shared.currentStatus()

        // Already answered, one way or the other
        if status != .notDetermined {
            return
        }

        let granted = await NotificationService.shared.requestPermission()

        // The reminders were booked during save, before permission existed.
        // Book them again now it does — same ids, so this replaces rather than duplicates.
        if granted {
            for assignment in course.assignments {
                NotificationService.shared.scheduleReminder(for: assignment)
            }
        }
    }

    // MARK: - Ask for a Review
    // Only asks from the 2nd saved syllabus onward — on the first one
    // the user is still trying Sylly out.
    private func askForReviewIfReady() async {

        successfulSaveCount += 1

        if successfulSaveCount < 2 {
            return
        }

        // Let them see "You're all set!" first. Cancelled if they leave the screen.
        do {
            try await Task.sleep(for: .seconds(2))
        } catch {
            return
        }

        // iOS decides whether to actually show it (max 3 per user per year)
        requestReview()
    }

    // MARK: - Add to Calendar
    // Runs when user taps the green button
    private func addToCalendar() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        calendarState = .loading

        Task {
            do {
                // Step 1: Ask for calendar permission
                let granted = try await CalendarService.shared.requestAccess()

                if !granted {
                    await MainActor.run {
                        calendarState = .idle
                        showPermissionDeniedAlert = true
                    }
                    return
                }

                // Step 2: Export all assignments to Apple Calendar
                let result = await CalendarService.shared.exportAssignments(from: course)

                // Step 3: Save calendarEventIDs so duplicate exports are prevented
                if result.successCount > 0 {
                    await MainActor.run { try? modelContext.save() }
                }

                // Step 4: Update UI based on results
                await MainActor.run {
                    if result.failedTitles.isEmpty {
                        // All exported!
                        calendarState = .done
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                    } else if result.successCount > 0 {
                        // Some worked, some didn't
                        calendarState = .done
                        failedExportTitles = result.failedTitles
                        showPartialFailureAlert = true
                    } else {
                        // Everything failed — let them retry
                        calendarState = .idle
                        failedExportTitles = result.failedTitles
                        showPartialFailureAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    calendarState = .idle
                    showCalendarErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Calendar Button State
// Controls the "Add to Calendar" button's text and color
enum CalendarButtonState: Equatable {
    case idle     // "Add to Calendar"
    case loading  // "Adding..."
    case done     // "Added to Calendar"

    var label: String {
        switch self {
        case .idle:    return "Add to Calendar"
        case .loading: return "Adding..."
        case .done:    return "Added to Calendar"
        }
    }

    var buttonColor: Color {
        switch self {
        case .idle:    return AppColors.primary
        case .loading: return AppColors.primary.opacity(0.7)
        // Green only once it worked — confirmation, not invitation.
        case .done:    return .green
        }
    }
}

// MARK: - Preview
#Preview {
    let course = Course(name: "Intro to AI", code: "CAP 4630")

    SuccessView(
        assignmentCount: 5,
        course: course,
        navigationState: .constant(.success(5, course)),
        selectedTab: .constant(0)
    )
}
