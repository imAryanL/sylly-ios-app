//
//  SyllyApp.swift
//  Sylly
//
//

import SwiftUI
import SwiftData


@main // The "Starting Point" of the app
struct SyllyApp: App {
    var body: some Scene {
        WindowGroup {
            // This is the first screen the user sees (3-tab layout)
            ContentView()
        }
        // This creates the REAL database for your Courses and Assignments
        // It saves data permanently so it doesn't disappear
        .modelContainer(for: [Course.self, Assignment.self])
    }
}
