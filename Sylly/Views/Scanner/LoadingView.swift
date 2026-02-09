//
//  LoadingView.swift
//  Sylly
//
//  This view shows a loading animation while:
//  1. OCR extracts text from the syllabus image
//  2. Claude API parses the text into assignments
//

import SwiftUI
import Combine

struct LoadingView: View {

    // MARK: - Properties
    let image: UIImage?

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // MARK: - State Properties
    // Tracks the animated dots (. → .. → ... → ....)
    @State private var dotCount = 0

    // Controls the pulsing animation
    @State private var isAnimating = false

    // Status message shown to user
    @State private var statusMessage = "Extracting text..."

    // Stores any error that occurs
    @State private var errorMessage: String?

    // When true, shows the ReviewView with parsed data
    @State private var showReview = false

    // Stores the parsed results from Claude
    @State private var parsedSyllabus: ParsedSyllabus?

    // MARK: - Timer
    // Timer for the dot animation (fires every 0.5 seconds)
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Animated Icon
            ZStack {
                // Document icon
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.primary)

                // Pulsing frame around the icon
                RoundedRectangle(cornerRadius: 50)
                    .stroke(AppColors.primary, lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)
            }
            .onAppear {
                // Start the pulsing animation
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }

            // MARK: - Title with Animated Dots
            Text("Analyzing Syllabus\(String(repeating: ".", count: dotCount))")
                .font(.title2)
                .fontWeight(.semibold)

            // MARK: - Status Message
            // Shows current step: "Extracting text..." or "Finding assignments..."
            Text(statusMessage)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // MARK: - Error Message (if any)
            if let error = errorMessage {
                VStack(spacing: 12) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Retry button
                    Button(action: {
                        errorMessage = nil
                        startProcessing()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(AppColors.primary)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 8)
            }

            Spacer()

            // MARK: - Cancel Button
            Button(action: {
                navigationState = .home
            }) {
                Text("Cancel")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))

        // MARK: - Dot Animation Timer
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % 4
        }

        // MARK: - Start Processing When View Appears
        .onAppear {
            startProcessing()
        }

        // MARK: - Navigate to ReviewView
        // When parsing completes, show ReviewView with the parsed syllabus
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            // Check if review view should be shown
            if showReview, let syllabus = parsedSyllabus {
                navigationState = .reviewing(syllabus)
            }
        }
    }

    // MARK: - Processing Function
    // This runs OCR and Claude API
    private func startProcessing() {
        // Make sure we have an image
        guard let image = image else {
            errorMessage = "No image to process"
            return
        }

        // Run the processing in a background task
        Task {
            do {
                // Step 1: OCR - Extract text from image
                await MainActor.run {
                    statusMessage = "Extracting text..."
                }

                let scannerService = ScannerService()
                let extractedText = try await scannerService.extractText(from: image)

                // Debug: Print extracted text
                print("Extracted text:\n\(extractedText)")

                // Step 2: Claude API - Parse the text
                await MainActor.run {
                    statusMessage = "Finding assignments..."
                }

                let claudeService = ClaudeService()
                let syllabus = try await claudeService.parseSyllabus(from: extractedText)

                // Debug: Print parsed results
                print("Parsed syllabus: \(syllabus.courseName)")
                print("Found \(syllabus.assignments.count) assignments")

                // Step 3: Show ReviewView with results
                await MainActor.run {
                    parsedSyllabus = syllabus
                    showReview = true
                }

            } catch {
                // Something went wrong - show error
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LoadingView(image: UIImage(named: "TestSyllabus"), navigationState: .constant(.loading(nil)))
}
