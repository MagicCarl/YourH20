import SwiftUI
import Combine
import WatchConnectivity

final class WatchHydrationViewModel: NSObject, ObservableObject {
    // MARK: - Published State
    @Published var userProfile: UserProfile = .default
    @Published var dailyLogs: [String: DailyLog] = [:]

    // MARK: - Dependencies
    private let persistence = WatchPersistenceManager.shared
    private let healthKit = WatchHealthKitManager.shared
    private var session: WCSession?
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

    var todayTotalOunces: Double {
        todayLog.totalOunces
    }

    // MARK: - Init

    override init() {
        super.init()
        loadFromPersistence()
        lastCheckedDay = todayKey
        activateWatchConnectivity()

        Task {
            _ = await healthKit.requestAuthorization()
        }
    }

    // MARK: - Day Change

    func checkForDayChange() {
        let currentDay = todayKey
        if currentDay != lastCheckedDay {
            lastCheckedDay = currentDay
            objectWillChange.send()
        }
    }

    // MARK: - Actions

    func logGlass() {
        let entry = WaterEntry()
        var log = dailyLogs[todayKey] ?? DailyLog(date: Date())
        log.entries.append(entry)
        dailyLogs[todayKey] = log
        persistAll()
        sendLogGlassToPhone(entry: entry)

        Task {
            _ = await healthKit.saveWaterIntake(ounces: entry.ounces, date: entry.timestamp)
        }
    }

    // MARK: - Persistence

    private func loadFromPersistence() {
        if let profile = persistence.loadProfile() {
            userProfile = profile
        }
        dailyLogs = persistence.loadDailyLogs()
    }

    private func persistAll() {
        persistence.saveProfile(userProfile)
        persistence.saveDailyLogs(dailyLogs)
    }

    // MARK: - Watch Connectivity

    private func activateWatchConnectivity() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    private func sendLogGlassToPhone(entry: WaterEntry) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(entry),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }

        let message: [String: Any] = ["action": "logGlass", "entry": dict]

        if let session, session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        } else {
            session?.transferUserInfo(message)
        }
    }

    // MARK: - Apply State from Phone

    private func applyStateFromPhone(_ context: [String: Any]) {
        let decoder = JSONDecoder()

        if let profileData = context["userProfile"] as? Data,
           let profile = try? decoder.decode(UserProfile.self, from: profileData) {
            self.userProfile = profile
        }

        if let logsData = context["dailyLogs"] as? Data,
           let logs = try? decoder.decode([String: DailyLog].self, from: logsData) {
            self.dailyLogs = logs
        }

        persistAll()
    }
}

// MARK: - WCSessionDelegate

extension WatchHydrationViewModel: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        Task { @MainActor in
            self.applyStateFromPhone(applicationContext)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        Task { @MainActor in
            self.applyStateFromPhone(message)
        }
    }
}
