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
            Image("SyllyMain")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
            
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
            
            // MARK: - Celebration Icons
            HStack(spacing: 30) {
                // Party popper icon
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                // Sparkles icon (yellow)
                Image(systemName: "fireworks")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
            }
            .padding(.top, 8)
            
 
            Spacer()
        }
        .frame(maxWidth: .infinity)  // Make the VStack stretch to fill full screen width
    }
}

#Preview {
    // Show the empty state for testing
    EmptyCourseView()
}
