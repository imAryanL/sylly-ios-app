//
//  EmptyCourseView.swift
//  Sylly
//
//

import SwiftUI

struct EmptyCourseView: View {
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Top Spacer (Pushes Content Down)
            // This empty spacer pushes all content below it towards the center
            Spacer()
            
            // MARK: - Octo Icon
            // Bigger now that he's carrying the screen on his own.
            Image("SyllyMain")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            // MARK: - Main Heading
            // Large text saying "All done!"
            Text("All done!")
                .font(.title2)  // Large title text
                .fontWeight(.semibold)  // Make it bold
            
            // MARK: - Subtitle
            // Smaller text explaining why this screen is showing
            Text("No upcoming assignments\nfor this class")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)  // Center text (important for the line break)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)  // Make the VStack stretch to fill full screen width
    }
}

#Preview {
    // Show the empty state for testing
    EmptyCourseView()
}
