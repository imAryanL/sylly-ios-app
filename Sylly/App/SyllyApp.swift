//
//  SyllyApp.swift
//  Sylly
//
//

import SwiftUI
import SwiftData


@main // The "Starting Point" of the app
struct SyllyApp: App {

    // Tracks whether the splash screen animation is done
    @State private var splashFinished = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main app (always loaded behind the splash so it's ready)
                ContentView()

                // Splash screen — sits on top until its animation finishes
                if !splashFinished {
                    SplashView(isFinished: $splashFinished)
                        .transition(.opacity)    // Fades out smoothly
                        .zIndex(1)               // Keeps it on top during transition, determines the layering order of views—higher values sit on top of lower values
                }
            }
        }
        // This creates the real database for Courses and Assignments
        // It saves data permanently so it doesn't disappear
        .modelContainer(for: [Course.self, Assignment.self])
    }
}
