//
//  HomeView.swift
//  Sylly
//
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    // Query tells the app to go into the database and find every 'Course' you have saved and put them in a new list called 'courses'
    @Query private var courses: [Course]
    
    
    var body: some View {
        
        NavigationStack { // componenet that handles the sliding animation to the next screen when tapping on a course card
            Group {
                if courses.isEmpty {
                    EmptyHomeView()
                } else {
                    FilledHomeView(courses: courses)
                }
            }
            .navigationTitle("Sylly")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: Text("Settings Coming Soon")) {
                        Image(systemName: AppIcons.settings)
                            .foregroundColor(AppColors.primary)
                            .fontWeight(.bold)
                            
                        
                    }
                    
                }
                
            }
        }
    }
}
    
// This part defines what the screen looks like when there are courses
    struct FilledHomeView: View {
        
        let courses: [Course]
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Courses")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // For every course in database, it generates one CourseCard. If there's 5 courses, it makes 5 cards
                    ForEach(courses) { course in
                        NavigationLink(destination: Text("Course Detail Coming Soon")) {
                            CourseCard(course: course)
                        }
                        .buttonStyle(.plain)
                    }
                        // '+ Add another syllabus' button
                        Button(action: {
                            // I'll put the code to open the Camera/Scanner here later
                        }) {
                            Text("+ Add another syllabus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(12)
                            
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(AppColors.background)
        }
    }


#Preview {
    HomeView()
        // This sets up a temporary database so the Preview can show fake data while I design the UI.
        .modelContainer(for: Course.self, inMemory: true)
    
}
