//
//  SuccessView.swift
//  Sylly
//
//  Created by aryan on 1/30/26.
//

import SwiftUI

struct SuccessView: View {

    // MARK: - Environment & Navigation
    // @Environment(\.dismiss) provides a way to close/exit this full screen view
    // Tapping "View Calendar" or "Back to home" will dismiss this screen
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Checkmark Icon
            // Animated success indicator: blue circle with white checkmark
            // Uses ZStack to layer the circle background with the checkmark icon on top
            ZStack {
                // Blue circular background (120x120)
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 120, height: 120)

                // White bold checkmark in the center
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.white)
            }

            // MARK: - Title
            // Main success message
            Text("You're all set!")
                .font(.title)
                .fontWeight(.bold)

            // MARK: - Subtitle
            // Confirmation message showing how many assignments were added
            Text("3 assignments have been\nadded to your calendar.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            // MARK: - View Calendar Button
            // Primary action: Navigate to calendar tab to view added assignments
            Button(action: {
                // Dismiss this success screen and return to calendar
                dismiss()
            }) {
                Text("View Calendar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            // MARK: - Back to Home Link
            // Secondary action: Dismiss and return to home screen
            Button(action: {
                dismiss()
            }) {
                Text("Back to home")
                    .foregroundColor(AppColors.primary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Preview
#Preview {
    SuccessView()
}
