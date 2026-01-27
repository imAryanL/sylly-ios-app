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
        .gray
    ]
    
    // Background colors
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)
}

// MARK: - SF Symbols for Courses
struct AppIcons {   // icons that will be used in this app  for courses 
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

        
        // Page 2 (20 icons)
        "star.fill",                  // General/Favorite
        "camera.fill",                // Photography
        "creditcard.fill",            // Finance/Economics
        "paintpalette.fill",          // Art
        "pencil.and.outline",         // Writing
        "graduationcap.fill",         // Education
        "atom",                       // Physics
        "heart.fill",                 // Health/Wellness
        "hammer.fill",                // Shop/Construction
        "sportscourt.fill",           // Physical Education
        "airplane",                   // Travel/Aviation
        "cross.case.fill",            // Nursing/First Aid
        "scalemass.fill",             // Physics/Measurements
        "cpu.fill",                   // Computer Hardware
        "network",                    // Networking/IT
        "dollarsign.circle.fill",     // Economics/Money
        "person.3.fill",              // Sociology/Groups
        "waveform.path.ecg",          // Biology/Health
        "testtube.2",                 // Lab Science
        "books.vertical.fill",        // Library/Research
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
enum AssignmentType: String, Codable, CaseIterable {
    case exam = "Exam"
    case quiz = "Quiz"
    case homework = "HW"
    case project = "Project"
}
