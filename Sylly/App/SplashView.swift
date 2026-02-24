//
//  SplashView.swift
//  Sylly
//

import SwiftUI

struct SplashView: View {

    @State private var logoScale: CGFloat = 0.5    // Start a bit smaller
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20    // NEW: Start text slightly lower

    @Binding var isFinished: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("SyllyMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    // NEW: A subtle shadow makes the logo pop off the background
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 8)

                Text("Sylly")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundColor(AppColors.primary)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
            }
        }
        .onAppear {
            // Step 1: Logo pops in with a slightly bouncier spring
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 10)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Step 2: Text slides up and fades in shortly after
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                textOpacity = 1.0
                textOffset = 0 // Slides up to its final position
            }
        }
        // Step 3: Dismiss splash (uses .task so it auto-cancels if view disappears)
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.3)) {
                isFinished = true
            }
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
