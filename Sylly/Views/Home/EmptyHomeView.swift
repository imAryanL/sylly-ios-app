//
//  EmptyHomeView.swift
//  Sylly
//
//  Created by aryan on 1/26/26.
//

import SwiftUI

struct EmptyHomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Placeholder icon
            Image(systemName: "sparkles")
                .font(.system(size: 100))
                .foregroundColor(AppColors.primary)
            
            Text("No syllabi yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Scan your first one to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
              // This is where I'll eventually put the code to open the camera
            }) {
                Text("Scan your syllabus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .background(AppColors.background)
    }
}

#Preview {
    EmptyHomeView()
}
