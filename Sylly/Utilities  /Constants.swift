//
//  Constants.swift
//  Sylly
//

import SwiftUI

// MARK: - App Colors
struct AppColors {
    // Primary brand color (from Assets)
    static let primary = Color("BrandPrimary")

    // Urgency colors
    static let urgent = Color.red              // Due in 1-2 days
    static let warning = Color.orange          // Due in 3-7 days
    static let neutral = Color.gray            // Due in 1+ weeks

    // Course colors (for icon backgrounds)
    static let courseColors: [Color] = [
        Color("BrandPrimary"),
        .red,
        .green,
        .orange,
        .blue,
        .pink,
        .purple,
        .black,
        .gray,
        .yellow,
    ]

    // Background colors
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)

    // MARK: - Color from String
    // Converts a color name string (stored in the database) to an actual SwiftUI Color.
    // Used everywhere a course's color needs to be displayed.
    // This is the SINGLE source of truth — don't duplicate this elsewhere!
    static func color(from name: String) -> Color {
        switch name.lowercased() {
        case "brandprimary": return Color("BrandPrimary")
        case "red": return .red
        case "green": return .green
        case "orange": return .orange
        case "blue": return Color("ICON_Blue")
        case "pink": return Color("ICON_Pink")
        case "purple": return Color("ICON_Purple")
        case "yellow": return .yellow
        case "black": return .black
        case "gray": return .gray
        default: return Color("BrandPrimary")
        }
    }
}

// MARK: - SF Symbols for Courses
struct AppIcons {   // icons that will be used in this app for courses 
    static let courseIcons: [String] = [
        "book.closed.fill",           // Book/Reading
        "brain.head.profile",         // Psychology/AI
        "function",                   // Math f(x)
        "flask.fill",                 // Chemistry/Science
        "laptopcomputer",             // Computer Science
        "lightbulb.fill",             // Ideas/General
        "puzzlepiece.fill",           // Problem Solving
        "globe.americas.fill",        // Geography/World
        "text.book.closed.fill",      // Literature
        "bubble.left.fill",           // Communications/Language
        "music.note",                 // Music
        "gearshape.fill",             // Engineering
        "chart.bar.fill",             // Statistics/Business
        "briefcase.fill",             // Business
        "building.columns.fill",      // History/Government
        "newspaper.fill",             // Journalism/News
        "video.fill",                 // Film/Video
        "theatermasks.fill",          // Theater/Drama
        "stethoscope",                // Health/Medical
        "leaf.fill",                  // Biology/Nature
        "figure.run",                 // Physical Education
        "banknote.fill",              // Finance/Accounting
        "wrench.and.screwdriver.fill", // Shop/Engineering
        "bolt.fill",                  // Electrical/Physics
        "pill.fill",                  // Pharmacy/Health
        

        
        // Page 2 (25 icons)
        "star.fill",                  // General/Favorite
        "camera.fill",                // Photography
        "creditcard.fill",            // Finance/Economics
        "paintpalette.fill",          // Art
        "pencil.and.outline",         // Writing
        "graduationcap.fill",         // Education
        "atom",                       // Physics
        "heart.fill",                 // Health/Wellness
        "pencil.line",                // Writing/English
        "sportscourt.fill",           // Physical Education
        "plus.forwardslash.minus",    // Math/Calculator
        "allergens",                 // Biology/Lab Science
        "scalemass.fill",             // Physics/Measurements
        "cpu.fill",                   // Computer Hardware
        "network",                    // Networking/IT
        "dollarsign.circle.fill",     // Economics/Money
        "person.3.fill",              // Sociology/Groups
        "waveform.path.ecg",          // Biology/Health
        "testtube.2",                 // Lab Science
        "books.vertical.fill",        // Library/Research
        "doc.text.fill",              // Research/Documents
        "square.and.pencil",          // Essay/Notes
        "quote.bubble.fill",          // Speech/Debate
        "clock.fill",                 // History/Time
        "map.fill",                   // Geography/Maps
    ]
        
    // Tab bar icons
    static let homeTab = "house.fill"
    static let scanTab = "plus.circle.fill"
    static let calendarTab = "calendar"
    
    // Common UI icons
    static let settings = "gearshape"
    static let chevronRight = "chevron.right"
    static let chevronLeft = "chevron.left"
    static let checkmark = "checkmark.circle.fill"
    static let circle = "circle"
    static let trash = "trash"
    static let edit = "pencil"
    static let camera = "camera.fill"
    static let photo = "photo"
    static let flash = "bolt.fill"
    static let close = "xmark"
    static let sparkles = "sparkles"
}

// MARK: - Assignment Types
// Enum: A type that defines a fixed list of related options (no other values allowed)
// This prevents typos and bugs by restricting assignment types to these 4 values only
//
// Protocols:
// • String: Each case has an associated String value (exam = "Exam", etc.)
// • Codable: Can convert to/from JSON for saving/loading from database
// • CaseIterable: Can loop through all cases with .allCases
enum AssignmentType: String, Codable, CaseIterable {
    // Internal name (used in code) = Display name (shown to users/saved to database)
    case exam = "Exam"
    case quiz = "Quiz"
    case homework = "HW"
    case project = "Project"
}
