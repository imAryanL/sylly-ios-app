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

    // Used when the normal reminder day has already passed — someone added an exam
    // three days out and the 7-day reminder is in the past. Returns the next 6pm
    // that still lands before it's due, or nil if there's no room left.
    func lateReminderDate(before dueDate: Date) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        guard var candidate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) else {
            return nil
        }

        // 6pm today is already gone, so aim for tomorrow
        if candidate < now {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: candidate) else {
                return nil
            }
            candidate = tomorrow
        }

        // Even the next 6pm is past the deadline — added at 7pm, due 9am tomorrow.
        // Give them an hour's notice instead of nothing at all. Not 5 minutes: that
        // fires while the phone is still in their hand.
        if candidate >= dueDate {
            guard let soon = calendar.date(byAdding: .hour, value: 1, to: now) else {
                return nil
            }

            if soon >= dueDate {
                return nil
            }

            return soon
        }

        return candidate
    }

    // Books one reminder for an assignment, at 6pm the right number of days before.
    // Uses the assignment's id so the reminder can be cancelled later.
    func scheduleReminder(for assignment: Assignment) {
        let leadDays = defaultLeadDays(for: assignment.type)
        let calendar = Calendar.current

        // Wind back from the due date, then pin it to 6pm — a lot of assignments
        // have no real time set and show as midnight, which is useless to notify at.
        guard let remindDay = calendar.date(byAdding: .day, value: -leadDays, to: assignment.dueDate),
              var fireDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: remindDay) else {
            return
        }

        // Added late, so the normal reminder day is behind us. Take the next 6pm
        // that still beats the due date rather than booking nothing at all.
        if fireDate < Date() {
            guard let lateDate = lateReminderDate(before: assignment.dueDate) else {
                return
            }
            fireDate = lateDate
        }

        // Count from when it actually fires, not from leadDays — a late reminder
        // goes out tonight and would otherwise still claim "due in 7 days".
        let fireDay = calendar.startOfDay(for: fireDate)
        let dueDay = calendar.startOfDay(for: assignment.dueDate)
        let daysLeft = calendar.dateComponents([.day], from: fireDay, to: dueDay).day ?? leadDays

        var dueText = "due in \(daysLeft) days"
        if daysLeft == 1 {
            dueText = "due tomorrow"
        }
        if daysLeft == 0 {
            dueText = "due today"
        }

        let content = UNMutableNotificationContent()
        content.title = assignment.title
        content.body = "\(assignment.course?.name ?? "Sylly") · \(dueText)"
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
        let request = FetchDescriptor<Assignment>()

        // Read before wiping — cancelling first meant a failed read left zero
        // reminders and nothing to rebuild them from.
        guard let assignments = try? context.fetch(request) else {
            print("Couldn't read assignments — leaving the existing reminders alone")
            return
        }

        cancelAll()

        for assignment in assignments {
            // Ticked off already — nothing to remind about
            if assignment.isCompleted {
                continue
            }
            scheduleReminder(for: assignment)
        }
    }

}
