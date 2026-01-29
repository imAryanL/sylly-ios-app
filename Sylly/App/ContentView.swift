//
//  ContentView.swift
//  Sylly
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Image(systemName: AppIcons.homeTab)
                    Text("Home")
                }
                .tag(0)
            
            // Tab 2: Scan (placeholder for now)
            Text("Scanner Coming Soon")
                .tabItem {
                    Image(systemName: AppIcons.scanTab)
                    Text("Scan")
                }
                .tag(1)
            
            // Tab 3: Calendar/Schedule
            ScheduleView()  
                .tabItem {
                    Image(systemName: AppIcons.calendarTab)
                    Text("Calendar")
                }
                .tag(2)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
