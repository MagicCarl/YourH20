import Foundation
import UserNotifications

final class NotificationManager: NSObject, @unchecked Sendable, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let notificationPrefix = "h2o-reminder-"

    private let messages = [
        "Time for a glass of water! Your body will thank you. 💧",
        "Stay hydrated! Grab some H2O.",
        "Water break! You're doing great. 💪",
        "Drink up! Keep that hydration going.",
        "Your body needs water — take a sip!",
        "Hydration check! Have you had your water?",
        "Water is fuel. Fill up your tank!",
        "A glass of water a day keeps dehydration away!",
        "Quick reminder: your body is 60% water. Keep it topped off!",
        "You're on track — grab another glass! 🥤"
    ]

    override init() {
        super.init()
    }

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Scheduling

    func scheduleReminders(profile: UserProfile, glassesRemaining: Int) {
        cancelAllReminders()

        guard glassesRemaining > 0 else { return }

        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        guard let endTime = calendar.date(bySettingHour: profile.sleepHour, minute: 0, second: 0, of: today) else { return }

        // If it's already past bedtime, don't schedule
        if now >= endTime { return }

        // Start 30 minutes from now at earliest
        let startTime = now.addingTimeInterval(30 * 60)
        if startTime >= endTime { return }

        let remainingSeconds = endTime.timeIntervalSince(startTime)
        var intervalSeconds = remainingSeconds / Double(glassesRemaining)

        // Minimum 30-minute gap
        intervalSeconds = max(intervalSeconds, 30 * 60)

        let count = min(glassesRemaining, 60)

        for i in 0..<count {
            let triggerDate = startTime.addingTimeInterval(Double(i) * intervalSeconds)
            if triggerDate >= endTime { break }

            let content = UNMutableNotificationContent()
            content.title = "H2O Reminder"
            content.body = messages[i % messages.count]
            content.sound = .default

            let components = calendar.dateComponents([.hour, .minute], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let request = UNNotificationRequest(
                identifier: "\(notificationPrefix)\(i)",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }

    func cancelAllReminders() {
        center.getPendingNotificationRequests { [weak self] requests in
            guard let prefix = self?.notificationPrefix else { return }
            let ids = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }
            self?.center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
