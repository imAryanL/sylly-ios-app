//
//  SplashView.swift
//  Sylly
//

import SwiftUI

struct SplashView: View {

    @State private var logoScale: CGFloat = 0.2    // Small enough that the growth reads
    @State private var logoOffset: CGFloat = -40   // Drops into place, so it moves as well as grows
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 44    // Far enough that the slide is visible

    @Binding var isFinished: Bool

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Image("SyllyMain")
                    .resizable()
                    .scaledToFit()
                    // The asset carries ~1/3 transparent padding, so 240 renders about 160pt of octopus.
                    .frame(width: 240, height: 240)
                    .scaleEffect(logoScale)
                    .offset(y: logoOffset)
                    .opacity(logoOpacity)
                    // NEW: A subtle shadow makes the logo pop off the background
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 10, x: 0, y: 8)

                Text("Sylly")
                    .font(.system(size: 56, weight: .heavy, design: .rounded))
                    .foregroundColor(AppColors.primary)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
            }
        }
        .onAppear {
            // Step 1: Logo drops in and grows. Low damping is what makes it bounce
            // instead of easing in.
            withAnimation(.interpolatingSpring(stiffness: 60, damping: 6.5)) {
                logoScale = 1.0
                logoOffset = 0
                logoOpacity = 1.0
            }

            // Step 2: Text slides up and fades in shortly after
            withAnimation(.easeOut(duration: 0.7).delay(0.45)) {
                textOpacity = 1.0
                textOffset = 0 // Slides up to its final position
            }
        }
        // Step 3: Dismiss splash (uses .task so it auto-cancels if view disappears)
        .task {
            // The bounce needs time to settle before we fade out.
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            withAnimation(.easeInOut(duration: 0.3)) {
                isFinished = true
            }
        }
    }
}

#Preview {
    SplashView(isFinished: .constant(false))
}
