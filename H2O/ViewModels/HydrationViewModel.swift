import SwiftUI
import Combine
import WatchConnectivity

final class HydrationViewModel: ObservableObject {
    // MARK: - Published State
    @Published var userProfile: UserProfile = .default
    @Published var dailyLogs: [String: DailyLog] = [:]
    @Published var hasCompletedOnboarding: Bool = false
    @Published var notificationsEnabled: Bool = false
    @Published var healthKitAuthorized: Bool = false

    // MARK: - Dependencies
    private let persistence = PersistenceManager.shared
    private let notifications = NotificationManager.shared
    private let healthKit = HealthKitManager.shared
    private let connectivity = PhoneConnectivityService.shared
    private var cancellables = Set<AnyCancellable>()
    private var lastCheckedDay: String = ""

    // MARK: - Computed Properties

    var todayKey: String {
        DailyLog.dateFormatter.string(from: Date())
    }

    var todayLog: DailyLog {
        dailyLogs[todayKey] ?? DailyLog(date: Date())
    }

    var dailyGoalGlasses: Int {
        userProfile.dailyGlasses
    }

    var dailyGoalOunces: Double {
        userProfile.dailyOunces
    }

    var glassesConsumedToday: Int {
        todayLog.glassesConsumed
    }

    var glassesRemaining: Int {
        max(0, dailyGoalGlasses - glassesConsumedToday)
    }

    var todayProgress: Double {
        todayLog.progress(goal: dailyGoalGlasses)
    }

    var isGoalMet: Bool {
        glassesConsumedToday >= dailyGoalGlasses
    }

    var sortedHistory: [DailyLog] {
        dailyLogs.values.sorted { $0.date > $1.date }
    }

    var weeklyHistory: [DailyLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let key = DailyLog.dateFormatter.string(from: date)
            return dailyLogs[key] ?? DailyLog(date: date)
        }
    }

    // MARK: - Init

    init() {
        loadAll()
        lastCheckedDay = todayKey

        connectivity.watchDidLogGlass
            .receive(on: RunLoop.main)
            .sink { [weak self] entry in
                self?.handleWatchLoggedGlass(entry)
            }
            .store(in: &cancellables)
    }

    // MARK: - Day Change Detection

    func checkForDayChange() {
        let currentDay = todayKey
        if currentDay != lastCheckedDay {
            lastCheckedDay = currentDay
            objectWillChange.send()
            rescheduleNotifications()
        }
    }

    // MARK: - Actions

    func loadAll() {
        hasCompletedOnboarding = persistence.hasCompletedOnboarding
        notificationsEnabled = persistence.notificationsEnabled
        if let profile = persistence.loadProfile() {
            userProfile = profile
        }
        dailyLogs = persistence.loadDailyLogs()
    }

    func completeOnboarding(weight: Double, sex: BiologicalSex, age: Int) {
        userProfile = UserProfile(
            weightInPounds: weight,
            sex: sex,
            age: age,
            wakeUpHour: 7,
            sleepHour: 22
        )
        hasCompletedOnboarding = true
        persistence.hasCompletedOnboarding = true
        persistence.saveProfile(userProfile)
        syncToWatch()

        Task {
            let hkGranted = await healthKit.requestAuthorization()
            await MainActor.run {
                healthKitAuthorized = hkGranted
            }

            let notifGranted = await notifications.requestPermission()
            await MainActor.run {
                notificationsEnabled = notifGranted
                persistence.notificationsEnabled = notifGranted
                if notifGranted {
                    rescheduleNotifications()
                }
            }
        }
    }

    func logGlass() {
        let entry = WaterEntry()
        var log = dailyLogs[todayKey] ?? DailyLog(date: Date())
        log.entries.append(entry)
        dailyLogs[todayKey] = log
        persistAll()
        rescheduleNotifications()

        Task {
            _ = await healthKit.saveWaterIntake(ounces: entry.ounces, date: entry.timestamp)
        }
    }

    func undoLastGlass() {
        guard var log = dailyLogs[todayKey], !log.entries.isEmpty else { return }
        log.entries.removeLast()
        dailyLogs[todayKey] = log
        persistAll()
        rescheduleNotifications()

        Task {
            _ = await healthKit.deleteLastWaterSample()
        }
    }

    func updateProfile(weight: Double, sex: BiologicalSex, age: Int) {
        userProfile.weightInPounds = weight
        userProfile.sex = sex
        userProfile.age = age
        persistence.saveProfile(userProfile)
        rescheduleNotifications()
        syncToWatch()
    }

    func updateWakeUpHour(_ hour: Int) {
        userProfile.wakeUpHour = hour
        persistence.saveProfile(userProfile)
        rescheduleNotifications()
    }

    func updateSleepHour(_ hour: Int) {
        userProfile.sleepHour = hour
        persistence.saveProfile(userProfile)
        rescheduleNotifications()
    }

    func toggleNotifications(_ enabled: Bool) async {
        if enabled {
            let granted = await notifications.requestPermission()
            await MainActor.run {
                notificationsEnabled = granted
                persistence.notificationsEnabled = granted
                if granted {
                    rescheduleNotifications()
                }
            }
        } else {
            await MainActor.run {
                notificationsEnabled = false
                persistence.notificationsEnabled = false
                notifications.cancelAllReminders()
            }
        }
    }

    // MARK: - Watch Connectivity

    private func handleWatchLoggedGlass(_ entry: WaterEntry) {
        var log = dailyLogs[todayKey] ?? DailyLog(date: Date())
        log.entries.append(entry)
        dailyLogs[todayKey] = log
        persistAll()
        rescheduleNotifications()
        // Do NOT save to HealthKit — Watch already saved it
    }

    private func syncToWatch() {
        connectivity.sendStateToWatch(profile: userProfile, dailyLogs: dailyLogs)
    }

    // MARK: - Private

    private func rescheduleNotifications() {
        guard notificationsEnabled else { return }
        notifications.scheduleReminders(
            profile: userProfile,
            glassesRemaining: glassesRemaining
        )
    }

    private func persistAll() {
        persistence.saveProfile(userProfile)
        persistence.saveDailyLogs(dailyLogs)
        syncToWatch()
    }
}
