//
//  ScannerView.swift
//  Sylly
//
//  Created by aryan on 1/30/26.
//

import SwiftUI

struct ScannerView: View {

    // MARK: - Environment & Navigation
    // @Environment(\.dismiss) provides a way to close/exit this view and return to previous screen
    @Environment(\.dismiss) private var dismiss

    // MARK: - State Properties
    // Track whether flash is enabled or disabled
    @State private var isFlashOn = false

    // Controls whether to show the photo library picker (for selecting existing images)
    @State private var showPhotoPicker = false

    // Controls whether to show the loading/processing screen after user taps shutter button
    @State private var showLoading = false

    // MARK: - Body
    // ZStack layers views on top of each other (black background + UI elements)
    var body: some View {
        ZStack {
            // Black background to simulate an actual camera interface
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar (Close & Flash Buttons)
                HStack {
                    // Close button (X icon) - exits scanner and returns to home
                    // Uses fixed frame with bold icon for better tap target and appearance
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    // Flash toggle button - switches between bolt.fill (on) and bolt.slash.fill (off)
                    // Changes color to yellow when enabled, white when disabled
                    Button(action: {
                        isFlashOn.toggle()
                    }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title2)
                            .foregroundColor(isFlashOn ? .yellow : .white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // MARK: - Helper Text
                // Instructions telling user where to position the document
                Text("Align your syllabus within the frame")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 16)

                Spacer()

                // MARK: - Scan Frame (Corner Brackets)
                // ZStack with 4 corner brackets positioned at the corners
                // The brackets guide users to align their syllabus within the scanning area
                ZStack {
                    // Top Left Corner - bracket pointing into frame
                    CornerBracket(rotation: 0)
                        .position(x: 40, y: 40)

                    // Top Right Corner - bracket rotated 90 degrees
                    CornerBracket(rotation: 90)
                        .position(x: 260, y: 40)

                    // Bottom Left Corner - bracket rotated 270 degrees
                    CornerBracket(rotation: 270)
                        .position(x: 40, y: 340)

                    // Bottom Right Corner - bracket rotated 180 degrees
                    CornerBracket(rotation: 180)
                        .position(x: 260, y: 340)
                }
                .frame(width: 300, height: 380)
             

                Spacer()

                // MARK: - Bottom Bar (Photo Library, Shutter, Spacing)
                HStack {
                    // Photo library button - lets user pick existing image instead of taking new photo
                    Button(action: {
                        showPhotoPicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                    }

                    Spacer()

                    // Shutter button (main capture button) - circular white button with border
                    // Tapping this takes a photo and shows the loading screen
                    Button(action: {
                        takePhoto()
                    }) {
                        ZStack {
                            // Outer circle (white border)
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 75, height: 75)

                            // Inner circle (filled white)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 62, height: 62)
                        }
                    }

                    Spacer()

                    // Empty space (clear color) - balances the layout so shutter button is centered
                    Color.clear
                        .frame(width: 60, height: 60)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        // fullScreenCover: When showLoading becomes true, display LoadingView over entire screen
        .fullScreenCover(isPresented: $showLoading) {
            LoadingView()
        }
    }

    // MARK: - Helper Functions
    // Called when user taps the shutter button
    private func takePhoto() {
        // For now, just show loading screen
        // Later: This will actually capture photo from camera and process it with OCR
        showLoading = true
    }
}

// MARK: - Corner Bracket Component
// Draws one corner bracket (L-shaped white line) that can be rotated
// Takes a rotation parameter to position brackets at different corners
struct CornerBracket: View {
    var rotation: Double

    var body: some View {
        Path { path in
            // Move to starting point (bottom of bracket)
            path.move(to: CGPoint(x: 0, y: 40))
            // Draw line up (vertical part)
            path.addLine(to: CGPoint(x: 0, y: 0))
            // Draw line right (horizontal part)
            path.addLine(to: CGPoint(x: 40, y: 0))
        }
        // Stroke: Draw the path as a white line with rounded corners
        // lineWidth: 5 makes it thick enough to see clearly
        .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
        // Apply rotation based on the parameter (0, 90, 180, 270 degrees)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - Preview
#Preview {
    ScannerView()
}
