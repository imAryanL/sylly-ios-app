//
//  CourseErrorView.swift
//  Sylly
//
//

//
//  CourseErrorView.swift
//  Sylly
//

import SwiftUI

struct CourseErrorView: View {
    // Action to run when the user taps "Rescan"
    // This is a closure (a block of code) passed in from the parent view
    var onRescan: () -> Void

    var body: some View {
        // MARK: - Main Container
        VStack(spacing: 16) {
            
            // MARK: - Top Spacer (Pushes Content Down)
            Spacer()
            
            // MARK: - Sad Octo Icon
            // A sad face to show something went wrong
            Image("SyllySad")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
            
            // MARK: - Error Heading
            Text("Uh oh!")
                .font(.title2)
                .fontWeight(.semibold)
            
            // MARK: - Error Message
            // Explain what went wrong and what to do next
            Text("No assignments found. Try\nrescanning your syllabus.")
                .font(.subheadline)  // Small text
                .foregroundColor(.secondary)  // Gray color
                .multilineTextAlignment(.center)  // Center text (important for the line break)
            
            // MARK: - Rescan Button
            // Button to let users retry scanning their syllabus
            Button(action: {
                onRescan()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "document.viewfinder.fill")
                    Text("Rescan")
                }
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(25)
                    
            }
            .padding(.horizontal, 80)
            .padding(.top, 16)  // Extra space above the button
            
            // MARK: - Bottom Spacer (Balances Top Spacer)
            // This spacer balances the top one, keeping content centered vertically
            Spacer()
        }
        .frame(maxWidth: .infinity)  // Make the VStack stretch to fill full screen width
    }
}

#Preview {
    // Show the error state for testing in Xcode preview
    CourseErrorView(onRescan: { })
}
