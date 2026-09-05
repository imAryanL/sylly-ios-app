//
//  EmptyHomeView.swift
//  Sylly
//
//  Created by aryan on 1/26/26.
//

import SwiftUI

struct EmptyHomeView: View {

    // MARK: - Navigation
    // Binding to navigation state
    @Binding var navigationState: NavigationState

    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // First screen after install — a starting point, not an empty state.
            Image("SyllyMain")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)

            // Nav title already says Sylly.
            Text("Let's get started")
                .font(.title2)
                .fontWeight(.semibold)

            // Says what they get, not just what to tap.
            Text("Scan your syllabus and Sylly finds your assignments and due dates.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // MARK: - Scan Button
            // Navigate to scanning state when tapped
            Button(action: {
                navigationState = .scanning
            }) {
                Text("Scan your syllabus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    // Same sheen as the Scan cards.
                    .background(
                        ZStack {
                            AppColors.primary
                            // Lighter than the cards — on a short button it reads as a stripe.
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
                    // Stays round at any height, unlike a fixed radius.
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(AppColors.background)
    }
}

// MARK: - Preview
#Preview {
    EmptyHomeView(navigationState: .constant(.home))
}
