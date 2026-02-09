//
//  SuccessView.swift
//  Sylly
//
//  This view shows after successfully saving assignments
//

import SwiftUI

struct SuccessView: View {

    // MARK: - Properties
    let assignmentCount: Int

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // Separate binding for tab selection (needed to switch tabs after success)
    @Binding var selectedTab: Int
    
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
            
            // MARK: - Subtitle (uses the assignmentCount property)
            Text("\(assignmentCount) \(assignmentCount == 1 ? "assignment has" : "assignments have") been\nadded to your calendar.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            // MARK: - View Calendar Button
            // When tapped: go back to home and switch to Calendar tab
            Button(action: {
                selectedTab = 2                    // Switch to Calendar tab
                navigationState = .home            // Go back to home (clears all overlays)
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

            // MARK: - Back to Home Button
            // When tapped: go back to home screen
            Button(action: {
                selectedTab = 0                    // Stay on Home tab
                navigationState = .home            // Go back to home (clears all overlays)
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
    SuccessView(
        assignmentCount: 5,
        navigationState: .constant(.success(5)),
        selectedTab: .constant(0)
    )
}