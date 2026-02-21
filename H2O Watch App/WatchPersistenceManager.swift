import Foundation

final class WatchPersistenceManager {
    static let shared = WatchPersistenceManager()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let userProfile = "YourH20_user_profile"
        static let dailyLogs = "YourH20_daily_logs"
    }

    init() {
        self.defaults = UserDefaults(suiteName: "group.com.carlandrewsfooglewatch.H2O") ?? .standard
    }

    func saveProfile(_ profile: UserProfile) {
        if let data = try? encoder.encode(profile) {
            defaults.set(data, forKey: Keys.userProfile)
        }
    }

    func loadProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile) else { return nil }
        return try? decoder.decode(UserProfile.self, from: data)
    }

    func saveDailyLogs(_ logs: [String: DailyLog]) {
        if let data = try? encoder.encode(logs) {
            defaults.set(data, forKey: Keys.dailyLogs)
        }
    }

    func loadDailyLogs() -> [String: DailyLog] {
        guard let data = defaults.data(forKey: Keys.dailyLogs) else { return [:] }
        return (try? decoder.decode([String: DailyLog].self, from: data)) ?? [:]
    }
}
