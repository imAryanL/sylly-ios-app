//
//  ScannerService.swift
//  Sylly
//
//  This service handles OCR (Optical Character Recognition)
//  It takes an image and extracts readable text from it
//

import SwiftUI
import Vision

// MARK: - Scanner Service
// I'm using a class here to handle OCR logic for reading text from images
// Classes work better with the Vision framework for this purpose
class ScannerService {
    
    // MARK: - Multi-Image OCR
    // Takes an array of images (from multi-page scanner) and extracts text from all of them
    // Returns one big combined string with all the text from every page
    func extractText(from images: [UIImage]) async throws -> String {
        var allText: [String] = []

        for image in images {
            let pageText = try await extractText(from: image)
            allText.append(pageText)
        }

        let combined = allText.joined(separator: "\n\n")

        if combined.isEmpty {
            throw ScannerError.noTextFound
        }

        return combined
    }

    // MARK: - Single Image OCR
    // I call this function from other parts of the app when I need to scan an image
    // - async: This takes time to run, so my app won't freeze while processing
    // - throws: If something goes wrong, I throw an error
    func extractText(from image: UIImage) async throws -> String {
        
        // Step 1: Convert UIImage to CGImage
        // Vision framework needs CGImage format, not UIImage
        guard let cgImage = image.cgImage else {
            throw ScannerError.invalidImage
        }
        
        // Step 2: Create a request to find text in the image
        // telling Vision: "Scan this image and find all the text"
        // I'll store the found text in this array
        var recognizedText: [String] = []
        
        // Step 3: Set up the text recognition request
        // VNRecognizeTextRequest is Apple's built-in text reader
        let request = VNRecognizeTextRequest { request, error in
            
            // If something went wrong, I'll just return (I'll handle errors later)
            if let error = error {
                print("Vision error: \(error.localizedDescription)")
                return
            }
            
            // Get the results from Vision
            // Vision returns "observations" - each observation is a piece of text it found
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }
            
            // Loop through each piece of text Vision found
            for observation in observations {
                // Get the top candidate (Vision's best guess for what the text says)
                if let topCandidate = observation.topCandidates(1).first {
                    // Add this text to my array
                    recognizedText.append(topCandidate.string)
                }
            }
        }
        
        // Step 4: Configure the request for accuracy
        // .accurate = slower but better quality (good for documents)
        // .fast = faster but might miss some text
        request.recognitionLevel = .accurate
        
        // Enable language correction (helps fix spelling mistakes)
        request.usesLanguageCorrection = true
        
        // Step 5: Create a handler to process the image
        // The handler takes my image and runs the request on it
        // Creating handler with my image with no special options or no options at all
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Step 6: Run the request
        // This is where the actual text recognition happens
        // "try" because it might fail (blurry image, no text found, etc.)
        try handler.perform([request])
        
        // Step 7: Combine all the text pieces into one string
        // joined(separator: "\n") puts each piece of text on a new line
        let fullText = recognizedText.joined(separator: "\n")
        
        // Step 8: Return the result
        // If I didn't find any text, I throw an error
        if fullText.isEmpty {
            throw ScannerError.noTextFound
        }
        
        return fullText
    }
}

// MARK: - Scanner Errors
// Custom error types so I know what went wrong
// Error - real Swift error (can be thrown) 
// LocalizedError - showing human-readable messages to users
enum ScannerError: Error, LocalizedError {
    case invalidImage      // The image couldn't be processed
    case noTextFound       // Vision didn't find any text in the image

    // Human-readable error messages I show to the user
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Could not process the image. Please try again."
        case .noTextFound:
            return "No text found in the image. Please try a clearer photo."
        }
    }
}

// MARK: - Test Function
// This is just for testing - I'll remove it later
#Preview {
    TestScannerView()
}

// A simple view to test my scanner
struct TestScannerView: View {
    @State private var extractedText = "Tap the button to test OCR..."
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            // Show the test image
            Image("TestSyllabus")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .border(Color.gray)

            // Button to run OCR
            Button(action: {
                testOCR()
            }) {
                Text(isLoading ? "Scanning..." : "Test OCR")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isLoading)

            // Show the extracted text
            ScrollView {
                Text(extractedText)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
        }
        .padding()
    }

    // Function to test OCR
    private func testOCR() {
        isLoading = true

        // Get the test image from Assets
        guard let image = UIImage(named: "TestSyllabus") else {
            extractedText = "Error: Could not load TestSyllabus image"
            isLoading = false
            return
        }

        // Run OCR in background
        // Task starts background work so app doesn't freeze the app
        Task {
            // error handling setup 
            do {
                let scanner = ScannerService()
                // Run OCR on the image and wait for the results
                let text = try await scanner.extractText(from: image)

                // Success! Switch to main thread and update the UI
                // MainActor.run = "Jump from background thread to main thread"
                // (SwiftUI can ONLY update UI from the main thread)
                await MainActor.run {
                    extractedText = "SUCCESS!\n\n--- Extracted Text ---\n\n\(text)"
                    isLoading = false
                }
            } catch {
                // If OCR failed, catch the error and show it to the user
                // MainActor.run switches back to main thread for safe UI update
                await MainActor.run {
                    extractedText = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}