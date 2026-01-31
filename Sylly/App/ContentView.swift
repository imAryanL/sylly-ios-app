//
//  ContentView.swift
//  Sylly
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showScanner = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Image(systemName: AppIcons.homeTab)
                    Text("Home")
                }
                .tag(0)
            
            // Tab 2: Scan (fake tab - just opens scanner)
            Text("")
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
        .onChange(of: selectedTab) { oldValue, newValue in
            // If user taps Scan tab, open scanner and go back to previous tab
            if newValue == 1 {
                showScanner = true
                selectedTab = oldValue
            }
        }
        .fullScreenCover(isPresented: $showScanner) {
            ScannerView()
        }
    }
}


#Preview {
    ContentView()
        .modelContainer(for: [Course.self, Assignment.self], inMemory: true)
}
