//
//  AboutView.swift
//  Sylly
//
//  Simple About sheet showing app info, tagline, and developer credit.
//

import SwiftUI

struct AboutView: View {

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {

            Spacer()

            // MARK: - App Logo
            Image("SyllyMain")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .cornerRadius(24)

            // MARK: - App Name & Version
            Text("Sylly")
                .font(.title)
                .fontWeight(.bold)

            Text("v1.0.0")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // MARK: - Tagline
            Text("Scan. Extract. Never miss a deadline.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            // MARK: - Developer Credit
            Text("Made by Aryan")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview
#Preview {
    AboutView()
}
