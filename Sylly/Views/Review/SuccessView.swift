//
//  SuccessView.swift
//  Sylly
//
//  This view shows after successfully saving assignments.
//  Users can export their assignments to Apple Calendar from here.
//

import SwiftUI

struct SuccessView: View {

    // MARK: - Properties
    let assignmentCount: Int
    let course: Course  // The saved Course with all its assignments (for calendar export)

    // MARK: - Navigation
    @Binding var navigationState: NavigationState
    @Binding var selectedTab: Int

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

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Checkmark Icon
            ZStack {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }

            // MARK: - Title
            Text("You're all set!")
                .font(.title)
                .fontWeight(.bold)

            // MARK: - Subtitle
            // Says "saved to Sylly" because calendar export is a separate step below
            Text("\(assignmentCount) \(assignmentCount == 1 ? "assignment has" : "assignments have") been\nsaved to Sylly.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

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
                .background(calendarState.buttonColor)
                .cornerRadius(12)
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
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
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

                // Step 3: Update UI based on results
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
    case idle     // "Add to Calendar" (green)
    case loading  // "Adding..." (green, dimmed)
    case done     // "Added to Calendar" (green, checkmark)

    var label: String {
        switch self {
        case .idle:    return "Add to Calendar"
        case .loading: return "Adding..."
        case .done:    return "Added to Calendar"
        }
    }

    var buttonColor: Color {
        switch self {
        case .idle:    return .green
        case .loading: return .green.opacity(0.7)
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
