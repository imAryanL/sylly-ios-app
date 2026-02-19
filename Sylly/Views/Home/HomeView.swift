//
//  HomeView.swift
//  Sylly
//
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // MARK: - Database
    // Query tells the app to go into the database and find every 'Course' you have saved and put them in a new list called 'courses'
    @Query private var courses: [Course]

    // MARK: - Navigation
    // Binding to entire navigation state (cleaner than multiple booleans!)
    @Binding var navigationState: NavigationState

    // MARK: - Body
    var body: some View {

        NavigationStack { // componenet that handles the sliding animation to the next screen when tapping on a course card
            Group {
                if courses.isEmpty {
                    EmptyHomeView(navigationState: $navigationState)
                } else {
                    FilledHomeView(courses: courses, navigationState: $navigationState)
                }
            }
            .navigationTitle("Sylly")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: AppIcons.settings)
                            .foregroundColor(AppColors.primary)
                            .fontWeight(.bold)
                    }
                }
                
            }
        }
    }
}

// MARK: - Filled Home View
// This part defines what the screen looks like when there are courses
struct FilledHomeView: View {

    let courses: [Course]

    // MARK: - Navigation
    // Binding to entire navigation state
    @Binding var navigationState: NavigationState

    // MARK: - Helper: Next Due Date
    private func getNextDueDate(for course: Course) -> Date {

            // FILTER: Focused on only homework that isn't done yet
            // AND has a deadline in the future (ignores past-due or finished work)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let upcoming = course.assignments
                .filter { !$0.isCompleted && calendar.startOfDay(for: $0.dueDate) >= today }
                
                // SORT: Line them up by date so the soonest one is at index [0]
                // ($0 < $1) means 'earlier date comes first'
                .sorted { $0.dueDate < $1.dueDate }
            
            // RETURN: Give back the very first (most urgent) date
            // If there is no upcoming work, return 'distantFuture'
            // so this course sinks to the bottom of home screen
            return upcoming.first?.dueDate ?? Date.distantFuture
        }

        // MARK: - Computed Property: Sorted Courses
        private var sortedCourses: [Course] {
            courses.sorted { course1, course2 in
                let date1 = getNextDueDate(for: course1)
                let date2 = getNextDueDate(for: course2)
                
                // Return true if course1 is due sooner than course2
                return date1 < date2
            }
        }

        // MARK: - Body
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Courses")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // For every course in database, it generates one CourseCard. If there's 5 courses, it makes 5 cards
                    ForEach(sortedCourses) { course in
                        NavigationLink(destination: CourseDetailView(course: course, navigationState: $navigationState)) {
                            CourseCard(course: course)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                        // '+ Add another syllabus' button
                        // When tapped, navigate to scanning state
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            navigationState = .scanning
                        }) {
                            Text("+ Add another syllabus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(12)

                    }
                    .buttonStyle(PressableButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(AppColors.background)
        }
    }

// MARK: - Preview
#Preview {
    // Create a preview with sample data
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Course.self, Assignment.self, configurations: config)
    
    // Add sample courses
    let course1 = Course(
        name: "Intro to AI",
        code: "CAP 4630",
        icon: "brain.head.profile",
        color: "blue"
    )
    
    let course2 = Course(
        name: "English 2",
        code: "ENC 1102",
        icon: "book.closed.fill",
        color: "orange"
    )
    
    let course3 = Course(
        name: "Life Science",
        code: "BSC 1005",
        icon: "leaf.fill",
        color: "green"
    )
    
    // Add sample assignments to course1
    let assignment1 = Assignment(
        title: "Midterm Exam",
        dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
        type: "exam"
    )
    assignment1.course = course1
    course1.assignments.append(assignment1)
    
    // Add sample assignment to course2
    let assignment2 = Assignment(
        title: "Essay",
        dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
        type: "homework"
    )
    assignment2.course = course2
    course2.assignments.append(assignment2)
    
    // Add sample assignment to course3
    let assignment3 = Assignment(
        title: "Lab Report",
        dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
        type: "project"
    )
    assignment3.course = course3
    course3.assignments.append(assignment3)
    
    // Insert into container
    container.mainContext.insert(course1)
    container.mainContext.insert(course2)
    container.mainContext.insert(course3)

    return HomeView(navigationState: .constant(.home))
        .modelContainer(container)
}
