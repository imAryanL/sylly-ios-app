//
//  SuccessView.swift
//  Sylly
//
//  This view shows after successfully saving assignments
//

import SwiftUI

struct SuccessView: View {
    
    // MARK: - Properties
    // The number of assignments that were saved (passed from ReviewView)
    let assignmentCount: Int
    
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
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
            Button(action: {
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
            
            // MARK: - Back to Home Button
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
    SuccessView(assignmentCount: 5)
}