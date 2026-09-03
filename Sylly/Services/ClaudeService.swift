//
//  ClaudeService.swift
//  Sylly
//
//  Created by aryan on 2/2/26.
//
//  This service sends syllabus text to Claude API
//  and gets back structured assignment data
//

import Foundation
import SwiftUI

// MARK: - Claude Service
// Handles all communication with Claude API
class ClaudeService {

    // MARK: - API Configuration
    // API key loaded from Secrets.xcconfig via Info.plist → Config.swift
    // For App Store, move to a backend proxy so the key isn't in the app bundle
    private let apiKey = Config.claudeAPIKey
    private let apiURL = "https://api.anthropic.com/v1/messages"
    private let model = "claude-haiku-4-5-20251001"  // Fast & cheap model

    // MARK: - Main Function: Parse Syllabus
    // Takes raw text from OCR and returns structured course data
    // Input: String (raw syllabus text from the OCR)
    // Output: ParsedSyllabus (course name, code, and assignments)
    func parseSyllabus(from text: String) async throws -> ParsedSyllabus {

        // Step 1: Create the prompt for Claude
        // This tells Claude exactly what to do
        let systemPrompt = """
        You are a helpful assistant that extracts assignment information from college syllabi.

        Your job is to:
        1. Find the course name and course code
        2. Find ALL assignments, exams, quizzes, and projects with their due dates
        3. Pull out a few course policies, when the syllabus states them
        4. Return the data as JSON

        Rules:
        - Only include items that have a specific date
        - For assignment type, use one of: exam, quiz, homework, project
        - Format dates as YYYY-MM-DD
        - If you can't find a course code, use "N/A"

        Policy fields (late_policy, office_hours, grading_breakdown):
        - Copy the wording from the syllabus. Do not paraphrase, summarize or tidy it up.
        - If the syllabus does not state one, return null. Never guess a policy. A student
          may act on this, and an invented policy is far worse than a missing one.
        - Keep each under 300 characters. Trim to the part that answers the question.

        lead_days: a single whole number, how many days before the due date to remind the
        student. Between 1 and 30.
        - Match the work: a term paper needs more warning than a discussion post.
        - Return null when nothing about the assignment suggests a specific answer.

        detail: one short phrase under 60 characters describing the work, for use in a
        reminder notification (for example "Chapters 1-6"). Return null when the syllabus
        says nothing beyond the title.

        Return ONLY valid JSON in this exact format, no other text:
        {
          "course_name": "string",
          "course_code": "string",
          "late_policy": "string or null",
          "office_hours": "string or null",
          "grading_breakdown": "string or null",
          "assignments": [
            {
              "title": "string",
              "date": "YYYY-MM-DD",
              "type": "exam|quiz|homework|project",
              "lead_days": 7,
              "detail": "string or null"
            }
          ]
        }
        """

        // The full date, not just the year. A course running December into January has to
        // know which side of the boundary today sits on.
        let todayFormatter = DateFormatter()
        // POSIX locale so a non-Gregorian device calendar can't hand back a different year.
        todayFormatter.locale = Locale(identifier: "en_US_POSIX")
        todayFormatter.dateFormat = "yyyy-MM-dd"
        let today = todayFormatter.string(from: Date())

        let userMessage = """
        Today's date is \(today). Please extract the course information and assignments from this syllabus.

        Choosing the year for each date:
        - Professors reuse old syllabus templates, so a year printed in the text may be stale.
        - If the syllabus names a term (like "Spring 2027") that begins within 12 months of
          today, use that term's years.
        - Otherwise choose years that place the course in the present or near future, never
          entirely in the past.
        - Read the schedule in order. If the dates run past December into January, those
          January dates belong to the following year.

        Syllabus text:
        \(text)
        """

        // Step 2: Build the API request
        // This creates the HTTP request to send to Claude
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

        // Claude API headers that must be included 
        // Headers tell the API who I am and what format I'm using
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        // Step 3: Create the request body
        // This is the actual data I'm sending to Claude's API integration, SDK
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 4096,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": userMessage]
            ]
        ]

        // Convert the dictionary to JSON data
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        // Step 4: Send the request and wait for response
        // URLSession is Apple's tool for making network requests
        let (data, response) = try await URLSession.shared.data(for: request)

        // Step 5: Check if the request was successful
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

        // Step 6: Parse Claude's response
        // Claude returns JSON with the response inside "content"
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let responseText = firstContent["text"] as? String else {
            throw ClaudeError.parsingError
        }

        // Step 7: Clean up the response
        // Sometimes Claude wraps JSON in ```json blocks - remove them
        let cleanedResponse = responseText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Step 8: Parse the JSON into my Swift struct
        guard let jsonData = cleanedResponse.data(using: .utf8) else {
            throw ClaudeError.parsingError
        }

        let decoder = JSONDecoder()
        let parsedSyllabus = try decoder.decode(ParsedSyllabus.self, from: jsonData)

        return parsedSyllabus
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
            return "Could not parse the response. Please try again."
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
