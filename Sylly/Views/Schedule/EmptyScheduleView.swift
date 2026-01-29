//
//  EmptyScheduleView.swift
//  Sylly
//

import SwiftUI

struct EmptyScheduleView: View {
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            // Octopus mascot
            Image("SyllyMain")
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
 
            Text("No assignments due!")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You're all caught up for\ntoday. Enjoy your free time.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Coffee and headphones icons
            HStack(spacing: 40) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.brown)
                
                Image(systemName: "headphones")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
#Preview {
    EmptyScheduleView()
}
