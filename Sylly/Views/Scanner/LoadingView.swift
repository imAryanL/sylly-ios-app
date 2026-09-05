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
    let images: [UIImage]

    // MARK: - Navigation
    // Single binding to control entire navigation
    @Binding var navigationState: NavigationState

    // MARK: - State Properties
    // Which half of the scan is running. Drives the title and the subtitle.
    @State private var phase: ScanPhase = .reading

    // Stores any error that occurs
    @State private var errorMessage: String?

    // When true, shows the ReviewView with parsed data
    @State private var showReview = false

    // Stores the parsed results from Claude
    @State private var parsedSyllabus: ParsedSyllabus?

    // onAppear can fire more than once — this keeps the paid API call to one run
    @State private var hasStarted = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {

            Spacer()

            // MARK: - Scanning Animation
            // Hidden on failure — a scanner still sweeping under an error reads as stuck.
            if errorMessage == nil {
                ScanningDocument()

                Text(phase.title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(phaseDetail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // MARK: - Error Message (if any)
            if let error = errorMessage {
                VStack(spacing: 16) {
                    // Error message with icon and light red background
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.red)

                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

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
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 16)
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

        // MARK: - Start Processing When View Appears
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            startProcessing()
        }

        // MARK: - Navigate to ReviewView
        // Fires once, the moment parsing finishes. parsedSyllabus is set just before
        // showReview in the same block, so it's always ready by the time this runs.
        .onChange(of: showReview) {
            if let syllabus = parsedSyllabus {
                navigationState = .reviewing(syllabus)
            }
        }
    }

    // MARK: - Processing Function
    // This runs OCR and Claude API
    private func startProcessing() {
        // Make sure there are images to process
        guard !images.isEmpty else {
            errorMessage = "No images to process"
            return
        }

        // Run the processing in a background task
        Task {
            do {
                // Step 1: OCR - Extract text from all scanned pages
                await MainActor.run {
                    phase = .reading
                }

                let scannerService = ScannerService()
                let extractedText = try await scannerService.extractText(from: images)

                // Step 2: Claude API - Parse the text
                await MainActor.run {
                    phase = .finding
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

    // MARK: - Helpers
    private var phaseDetail: String {
        if phase == .reading {
            if images.count == 1 {
                return "1 page"
            }
            return "\(images.count) pages"
        }
        return "Dates, titles and course info"
    }
}

// MARK: - Scan Phase
enum ScanPhase: Equatable {
    case reading
    case finding

    var title: String {
        switch self {
        case .reading: return "Reading your pages"
        case .finding: return "Finding assignments"
        }
    }
}

// MARK: - Scanning Document
// A page outline with a light bar sweeping down it, brightening the lines it passes.
private struct ScanningDocument: View {
    // -1 is above the page, 1 is below it.
    @State private var sweep: CGFloat = -1

    private let pageWidth: CGFloat = 104
    private let pageHeight: CGFloat = 132
    private let lineWidths: [CGFloat] = [0.85, 0.6, 0.9, 0.5, 0.8, 0.7]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.primary.opacity(0.45), lineWidth: 3)
                .frame(width: pageWidth, height: pageHeight)

            textLines(opacity: 0.2)

            // The same lines at full strength, revealed only under the moving band.
            textLines(opacity: 1.0)
                .mask(sweepBand)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, AppColors.primary, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: pageWidth - 12, height: 2)
                .offset(y: sweep * (pageHeight / 2))
        }
        .frame(width: pageWidth, height: pageHeight)
        .onAppear {
            // withAnimation inside onAppear, so the repeat cannot capture a settling layout.
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                sweep = 1
            }
        }
    }

    private var sweepBand: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.0),
                .init(color: .white, location: 0.5),
                .init(color: .clear, location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: pageWidth, height: pageHeight * 0.55)
        .offset(y: sweep * (pageHeight / 2))
    }

    private func textLines(opacity: Double) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(lineWidths.indices, id: \.self) { index in
                Capsule()
                    .fill(AppColors.primary.opacity(opacity))
                    .frame(width: (pageWidth - 32) * lineWidths[index], height: 5)
            }
        }
        .frame(width: pageWidth - 32, alignment: .leading)
    }
}

// MARK: - Preview
// This one runs the real scan on appear — OCR plus a paid Claude call.
#Preview("Full scan — costs money") {
    LoadingView(images: [UIImage(named: "TestSyllabus")].compactMap { $0 }, navigationState: .constant(.loading([])))
}

// Just the animation, no processing.
#Preview("Scanning animation") {
    ScanningDocument()
}
