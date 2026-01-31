//
//  LoadingView.swift
//  Sylly
//
//  Created by aryan on 1/30/26.
//

import SwiftUI
import Combine

struct LoadingView: View {

    // MARK: - Environment & Navigation
    // @Environment(\.dismiss) provides a way to close/exit this loading screen
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    // Tracks how many dots to display in the "Analyzing..." text
    // Used to create the animated dot animation (. → .. → ... → repeats)
    @State private var dotCount = 0

    // Controls the scanning frame animation (scale and opacity pulsing)
    @State private var isAnimating = false

    // MARK: - Timer Setup
    // Timer that fires every 0.5 seconds on the main thread
    // This controls the speed of the dot animation
    // .autoconnect() starts the timer immediately when the view appears
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Animated Scan Icon
            // ZStack creates layers: document icon + animated scanning frame around it
            // The frame pulses in and out to show scanning activity
            ZStack {
                // Document icon in the center
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)

                // Animated scanning frame around the document
                // Scales up/down and changes opacity to create pulsing effect
                RoundedRectangle(cornerRadius: 50)
                    .stroke(AppColors.primary, lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)
            }
            // onAppear: Start the pulsing animation when view loads
            // easeInOut: Smooth acceleration/deceleration
            // repeatForever(autoreverses: true): Loop infinitely, reversing direction each time
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }

            // MARK: - Title with Animated Dots
            // Text that updates with animated dots: "Analyzing Syllabus" → "Analyzing Syllabus." → "Analyzing Syllabus.." etc.
            // The String(repeating:count:) creates the dots based on dotCount value
            Text("Analyzing Syllabus\(String(repeating: ".", count: dotCount))")
                .font(.title2)
                .fontWeight(.semibold)

            // MARK: - Subtitle
            // Descriptive text explaining what's happening in the background
            Text("Extracting dates and assignments...")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            // MARK: - Cancel Button
            // Allows user to cancel the scanning/analysis process if they change their mind
            // Dismisses this loading view and returns to the scanner
            Button(action: {
                dismiss()
            }) {
                Text("Cancel")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        // MARK: - Animation Handler
        // onReceive: Subscribes to the timer that fires every 0.5 seconds
        // Updates dotCount in a cycle: 0 → 1 → 2 → 3 → 0 → ...
        // The % 4 operator (modulo) wraps the count back to 0 after reaching 3
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }
    }
}

// MARK: - Preview
#Preview {
    LoadingView()
}
