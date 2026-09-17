//
//  ClaudeService.swift
//  Sylly
//
//  Created by aryan on 2/2/26.
//
//  This service sends syllabus text to the Sylly proxy
//  and gets back structured assignment data
//

import Foundation
import SwiftUI
import UIKit

// MARK: - Claude Service
// Talks to the Cloudflare worker, which holds the API key and the prompt.
class ClaudeService {

    // MARK: - API Configuration
    private let apiURL = "https://sylly-proxy.aryanl.workers.dev/scan"

    // MARK: - Main Function: Parse Syllabus
    // Takes raw text from OCR and returns structured course data
    // Input: String (raw syllabus text from the OCR)
    // Output: ParsedSyllabus (course name, code, and assignments)
    func parseSyllabus(from text: String) async throws -> ParsedSyllabus {

        // Step 1: Build the request
        // Points at the worker, not Anthropic
        guard let url = URL(string: apiURL) else {
            throw ClaudeError.invalidURL
        }

        // Creates a request object and gives it the API URL
        var request = URLRequest(url: url)
        // Back to URLSession's default. 30s was too tight — a long syllabus can take
        // that long to come back, and a timeout loses the scan after the tokens are paid for.
        request.timeoutInterval = 60
        // Set the HTTP method to POST which means to send data
        request.httpMethod = "POST"

        // No API key here any more — the proxy holds it. identifierForVendor is what the
        // proxy counts scans against, so one phone can't hammer it.
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device"
        request.setValue(deviceID, forHTTPHeaderField: "x-sylly-device")

        // Step 2: Create the request body
        // Just the text. Model, prompt and token limit live in the proxy now.
        let requestBody: [String: Any] = [
            "text": text
        ]

        // Convert the dictionary to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Step 3: Send the request and wait for response
        // URLSession is Apple's tool for making network requests
        let (data, response) = try await URLSession.shared.data(for: request)

        // Step 4: Check if the request was successful
        // HTTP 200 means "OK, it worked!"
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        // Using Claude HTTP Errors format for debugging if not working
        // If not 200, something went wrong
        if httpResponse.statusCode != 200 {
            // Try to get error message from response
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorInfo = errorJson["error"] as? [String: Any],
               let message = errorInfo["message"] as? String {
                throw ClaudeError.apiError(message)
            }
            throw ClaudeError.apiError("HTTP \(httpResponse.statusCode)")
        }

        // Step 5: Parse Claude's response
        // Claude returns JSON with the response inside "content"
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let responseText = firstContent["text"] as? String else {
            throw ClaudeError.parsingError
        }

        // Step 6: Clean up the response
        // Sometimes Claude wraps JSON in ```json blocks - remove them
        let cleanedResponse = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Step 7: Parse the JSON into my Swift struct
        guard let jsonData = cleanedResponse.data(using: .utf8) else {
            throw ClaudeError.parsingError
        }

        // Decode throws Foundation's own error, which reaches the user as
        // "the data couldn't be read". Everything else here throws a ClaudeError.
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(ParsedSyllabus.self, from: jsonData)
        } catch {
            throw ClaudeError.parsingError
        }
    }
}

// MARK: - Data Models
// These structs match the JSON format Claude returns

struct ParsedSyllabus: Codable {
    let courseName: String
    let courseCode: String
    let assignments: [ParsedAssignment]

    // Nil means the syllabus didn't say. Missing keys decode to nil on their own.
    // var, not let — a `let` with a default never gets decoded.
    var latePolicy: String? = nil
    var officeHours: String? = nil
    var gradingBreakdown: String? = nil

    // This maps JSON keys to Swift properties 
    // CodingKey tells Swift how to translate JSON keys to Swift Property names
    enum CodingKeys: String, CodingKey {
        case courseName = "course_name"
        case courseCode = "course_code"
        case assignments
        case latePolicy = "late_policy"
        case officeHours = "office_hours"
        case gradingBreakdown = "grading_breakdown"
    }
}

struct ParsedAssignment: Codable {
    let title: String
    let date: String      // Format: "YYYY-MM-DD"
    let type: String      // "exam", "quiz", "homework", "project"

    // Nil falls back to what the app already does: the 7/5/3/1 ladder, and a notification
    // body built from the title alone.
    var leadDays: Int? = nil
    var detail: String? = nil

    enum CodingKeys: String, CodingKey {
        case title
        case date
        case type
        case leadDays = "lead_days"
        case detail
    }
}

// MARK: - Claude Errors
// Custom error types for Claude API issues
enum ClaudeError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .parsingError:
            return "Sylly couldn't read that syllabus. Try scanning it again."
        }
    }
}

// MARK: - Test View
#Preview {
    TestClaudeView()
}

struct TestClaudeView: View {
    @State private var result = "Tap button to test Claude API..."
    @State private var isLoading = false

    // Sample text (simulating what OCR would return)
    let sampleText = """
    CAP 4630 - Intro to Artificial Intelligence
    Professor Smith | Spring 2025

    ASSIGNMENT SCHEDULE:
    Midterm Exam - February 12, 2025
    Problem Set 3 - February 18, 2025
    Quiz 2 - February 24, 2025
    Final Project - March 15, 2025
    Lab Report - March 22, 2025
    Final Exam - April 10, 2025
    """

    var body: some View {
        VStack(spacing: 20) {
            Text("Claude API Test")
                .font(.title)
                .fontWeight(.bold)

            // Show the sample text
            Text("Sample Input:")
                .font(.headline)

            Text(sampleText)
                .font(.system(.caption, design: .monospaced))
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)

            // Test button
            Button(action: {
                testClaude()
            }) {
                Text(isLoading ? "Processing..." : "Test Claude API")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isLoading ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            .padding(.horizontal)

            // Show results
            ScrollView {
                Text(result)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
        .padding()
    }

    private func testClaude() {
        isLoading = true
        result = "Sending to Claude..."

        // "Task" runs in the background so it doesn't freeze the app while waiting for Claude
        Task {
            do {
                let service = ClaudeService()
                let parsed = try await service.parseSyllabus(from: sampleText)

                await MainActor.run {   // Update UI on main thread
                    result = """
                    SUCCESS!

                    Course: \(parsed.courseName)
                    Code: \(parsed.courseCode)

                    Assignments Found: \(parsed.assignments.count)

                    \(parsed.assignments.map { "• \($0.title) - \($0.date) (\($0.type))" }.joined(separator: "\n"))
                    """
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    result = "Error: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}
