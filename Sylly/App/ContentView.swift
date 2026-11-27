//
//  ContentView.swift
//  Sylly
//

import SwiftUI
import SwiftData

// MARK: - Navigation State Enum
// One value drives the whole scan flow.
enum NavigationState {
    case home                              // Home screen (default)
    case scanning                          // Jump to the Scan tab
    case loading([UIImage])                // LoadingView, with the pages to read
    case reviewing(ParsedSyllabus)         // ReviewView, with the parsed syllabus
    case success(Int, Course)              // SuccessView, with the count + course for calendar export

    // ContentView: another screen asked to scan
    var isScanning: Bool {
        if case .scanning = self { return true }
        return false
    }

    // ScannerView: navigation went back home
    var isHome: Bool {
        if case .home = self { return true }
        return false
    }
}

struct ContentView: View {
    // MARK: - Database
    @Environment(\.modelContext) private var modelContext

    // Tells us when the app comes back to the foreground
    @Environment(\.scenePhase) private var scenePhase

    // Empty until the student connects Canvas
    @AppStorage("canvasFeedLink") private var canvasFeedLink = ""

    // MARK: - Navigation State
    @State private var navigationState: NavigationState = .home

    // MARK: - Tab Selection
    // 0 = Home, 1 = Scan, 2 = Calendar
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

                // Tab 2: Scanner
                ScannerView(navigationState: $navigationState)
                    .tabItem {
                        Image(systemName: AppIcons.scanTab)
                        Text("Scan")
                    }
                    .tag(1)

                // Tab 3: Calendar
                ScheduleView(navigationState: $navigationState)
                    .tabItem {
                        Image(systemName: AppIcons.calendarTab)
                        Text("Calendar")
                    }
                    .tag(2)
            }
            .tint(AppColors.primary)
            // e.g. "Add another syllabus" jumps to the Scan tab
            .onChange(of: navigationState.isScanning) { _, isScanning in
                if isScanning {
                    selectedTab = 1
                    navigationState = .home
                }
            }

            // MARK: - Navigation Overlays
            // Scan flow screens that slide up over the tabs
            if case .loading(let images) = navigationState {
                LoadingView(images: images, navigationState: $navigationState)
                    .transition(.move(edge: .bottom))
            }

            if case .reviewing(let syllabus) = navigationState {
                ReviewView(parsedSyllabus: syllabus, navigationState: $navigationState)
                    .transition(.move(edge: .bottom))
            }

            if case .success(let count, let course) = navigationState {
                SuccessView(assignmentCount: count, course: course, navigationState: $navigationState, selectedTab: $selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }

        // Cold launch — scenePhase is already .active here, so onChange never fires
        .task {
            await rebuildRemindersIfAllowed()
            await refreshCanvasIfLinked()
        }

        // Coming back to the app, e.g. from iOS Settings
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task {
                    await rebuildRemindersIfAllowed()
                    await refreshCanvasIfLinked()
                }
            }
        }
    }

    // Notifications can be turned on later in iOS Settings, so rebook on every open.
    private func rebuildRemindersIfAllowed() async {
        if await NotificationService.shared.currentStatus() == .authorized {
            NotificationService.shared.refreshAll(context: modelContext)
        }
    }

    // Offline or a dead link just fails quietly and tries again next open.
    private func refreshCanvasIfLinked() async {
        if canvasFeedLink.isEmpty {
            return
        }

        let canvas = CanvasService()
        do {
            let items = try await canvas.fetchAssignments(from: canvasFeedLink)
            canvas.saveItems(items, context: modelContext)
            print("Canvas refresh: \(items.count) items")
        } catch {
            print("Canvas refresh failed: \(error)")
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
