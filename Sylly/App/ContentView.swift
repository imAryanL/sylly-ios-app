//
//  ContentView.swift
//  Sylly
//
//

import SwiftUI

struct ContentView: View {
    // This keeps track of which tab (0, 1, or 2) is currently clicked
    @State private var selectedTab = 0
    
    var body: some View {
        // main container for the bottom navigation bar
        TabView (selection: $selectedTab) {
            
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Image(systemName: AppIcons.homeTab)
                    Text("Home")
                }
                .tag(0)  // ID number for the tab, ex. Home is Tag 0
            
            // Tab 2: Scan
            Text("Scanner Coming Soon")
                .tabItem {
                    Image(systemName: AppIcons.scanTab)
                    Text("Scan")
                }
                .tag(1)
            
            // Tab 3: Calendar/Schedule
            Text("Schedule Coming Soon")
                .tabItem {
                    Image(systemName: AppIcons.calendarTab)
                    Text("Calendar")
                }
                .tag(2)
        }
        .tint(AppColors.primary) // Makes the icons match my "Sylly" brand color
    }
}

#Preview {
    ContentView()
}
