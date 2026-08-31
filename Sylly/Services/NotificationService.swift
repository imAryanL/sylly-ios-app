//
//  NotificationService.swift
//  Sylly
//
//  Due-date reminders. Same shape as CalendarService — one shared instance
//  the rest of the app calls into. Everything here is local to the phone.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationService {
    static let shared = NotificationService()

    // Asks iOS for permission and returns whether the user allowed it.
    // The system popup only appears the first time. After that iOS hands back
    // the answer it already has without showing anything.
    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Notification permission failed: \(error.localizedDescription)")
            return false
        }
    }

    // What iOS currently thinks. Settings needs this because a toggle can't
    // turn notifications back on once the user has denied them — at that point
    // the only way back is the iOS Settings app.
    func currentStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    // How many days before the due date to remind, based on the kind of work.
    // Rough on purpose — a scan can later store a better number per assignment
    // and this stays the fallback for anything that doesn't have one.
    // Types are stored lowercase: exam, quiz, homework, project.
    func defaultLeadDays(for type: String) -> Int {
        switch type.lowercased() {
        case "exam":
            return 7
        case "project":
            return 5
        case "quiz":
            return 3
        default:
            return 1
        }
    }

    // Books one reminder for an assignment, at 6pm the right number of days before.
    // Uses the assignment's id so the reminder can be cancelled later.
    func scheduleReminder(for assignment: Assignment) {
        let leadDays = defaultLeadDays(for: assignment.type)
        let calendar = Calendar.current

        // Wind back from the due date, then pin it to 6pm — a lot of assignments
        // have no real time set and show as midnight, which is useless to notify at.
        guard let remindDay = calendar.date(byAdding: .day, value: -leadDays, to: assignment.dueDate),
              let fireDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: remindDay) else {
            return
        }

        // Already gone — nothing to book
        if fireDate < Date() {
            return
        }

        var dayWord = "days"
        if leadDays == 1 {
            dayWord = "day"
        }

        let content = UNMutableNotificationContent()
        content.title = assignment.title
        content.body = "\(assignment.course?.name ?? "Sylly") · due in \(leadDays) \(dayWord)"
        content.sound = .default

        let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)

        let request = UNNotificationRequest(
            identifier: assignment.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // Wipes every pending reminder.
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // Throws away every reminder and rebuilds them from what's actually saved.
    // Call this after anything that changes an assignment — added, edited,
    // completed, deleted. Rebuilding is cheap and local, and it means the
    // reminders can never drift out of step with the database.
    func refreshAll(context: ModelContext) {
        cancelAll()

        let assignments = (try? context.fetch(FetchDescriptor<Assignment>())) ?? []
        for assignment in assignments {
            scheduleReminder(for: assignment)
        }
    }

}
