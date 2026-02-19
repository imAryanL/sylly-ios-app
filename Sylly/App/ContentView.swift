//
//  ContentView.swift
//  Sylly
//

import SwiftUI
import SwiftData

// MARK: - Navigation State Enum
// Single source of truth for navigation in the app
// This replaces multiple @State booleans with one clear, hierarchical state
enum NavigationState {
    case home                              // Home screen (default)
    case scanning                          // Triggers switch to Scanner tab
    case loading([UIImage])                 // LoadingView (carries images to process)
    case reviewing(ParsedSyllabus)         // ReviewView (carries parsed data)
    case success(Int)                      // SuccessView (carries assignment count)

    // Helper so ContentView can detect when other views request scanning
    var isScanning: Bool {
        if case .scanning = self { return true }
        return false
    }
}

struct ContentView: View {
    // MARK: - Navigation State
    // Single @State that controls entire navigation flow
    // Much cleaner than multiple boolean flags
    @State private var navigationState: NavigationState = .home

    // MARK: - Tab Selection
    // Separate state for tab bar (0=Home, 1=Scan, 2=Calendar)
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // MARK: - Tab View (Main Navigation)
            TabView(selection: $selectedTab) {
                // Tab 1: Home
                HomeView(navigationState: $navigationState)
                    .tabItem {
                        Image(systemName: AppIcons.homeTab)
                        Text("Home")
                    }
                    .tag(0)

                // Tab 2: Scanner (real tab with Launch Pad cards)
                ScannerView(navigationState: $navigationState)
                    .tabItem {
                        Image(systemName: AppIcons.scanTab)
                        Text("Scan")
                    }
                    .tag(1)

                // Tab 3: Calendar/Schedule
                ScheduleView(navigationState: $navigationState)
                    .tabItem {
                        Image(systemName: AppIcons.calendarTab)
                        Text("Calendar")
                    }
                    .tag(2)
            }
            .tint(AppColors.primary)
            // When other views set .scanning (e.g. "Add another syllabus"),
            // switch to the Scanner tab and reset navigation state
            .onChange(of: navigationState.isScanning) { _, isScanning in
                if isScanning {
                    selectedTab = 1
                    navigationState = .home
                }
            }

            // MARK: - Navigation Overlays
            // These overlay the tab view for the scan pipeline
            // (Scanner itself is now a real tab, not an overlay)
            if case .loading(let images) = navigationState {
                LoadingView(images: images, navigationState: $navigationState)
                    .transition(.move(edge: .bottom))
            }

            if case .reviewing(let syllabus) = navigationState {
                ReviewView(parsedSyllabus: syllabus, navigationState: $navigationState)
                    .transition(.move(edge: .bottom))
            }

            if case .success(let count) = navigationState {
                SuccessView(assignmentCount: count, navigationState: $navigationState, selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
