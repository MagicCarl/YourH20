import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let userProfile = "YourH20_user_profile"
        static let dailyLogs = "YourH20_daily_logs"
        static let hasCompletedOnboarding = "YourH20_onboarding_complete"
        static let notificationsEnabled = "YourH20_notifications_enabled"
        static let migratedToAppGroup = "YourH20_migrated_to_app_group"
    }

    private init() {
        self.defaults = UserDefaults(suiteName: "group.com.carlandrewsfooglewatch.H2O") ?? .standard
        migrateOldKeysIfNeeded()
        migrateToAppGroupIfNeeded()
    }

    // MARK: - Migration

    /// Migrate data saved under old key names to the current keys
    private func migrateOldKeysIfNeeded() {
        let oldKeys = [
            ("Your H20_user_profile", Keys.userProfile),
            ("Your H20_daily_logs", Keys.dailyLogs),
            ("Your H20_onboarding_complete", Keys.hasCompletedOnboarding),
            ("Your H20_notifications_enabled", Keys.notificationsEnabled),
            ("h2o_user_profile", Keys.userProfile),
            ("h2o_daily_logs", Keys.dailyLogs),
            ("h2o_onboarding_complete", Keys.hasCompletedOnboarding),
            ("h2o_notifications_enabled", Keys.notificationsEnabled),
        ]
        for (oldKey, newKey) in oldKeys {
            if defaults.object(forKey: newKey) == nil, let value = defaults.object(forKey: oldKey) {
                defaults.set(value, forKey: newKey)
            }
        }
        // Also check UserDefaults.standard for the old keys
        let standard = UserDefaults.standard
        for (oldKey, newKey) in oldKeys {
            if defaults.object(forKey: newKey) == nil, let value = standard.object(forKey: oldKey) {
                defaults.set(value, forKey: newKey)
            }
        }
    }

    private func migrateToAppGroupIfNeeded() {
        guard !defaults.bool(forKey: Keys.migratedToAppGroup) else { return }

        let standard = UserDefaults.standard

        if let data = standard.data(forKey: Keys.userProfile) {
            defaults.set(data, forKey: Keys.userProfile)
        }
        if let data = standard.data(forKey: Keys.dailyLogs) {
            defaults.set(data, forKey: Keys.dailyLogs)
        }
        if standard.bool(forKey: Keys.hasCompletedOnboarding) {
            defaults.set(true, forKey: Keys.hasCompletedOnboarding)
        }
        if standard.bool(forKey: Keys.notificationsEnabled) {
            defaults.set(true, forKey: Keys.notificationsEnabled)
        }

        defaults.set(true, forKey: Keys.migratedToAppGroup)
    }

    // MARK: - Profile

    func saveProfile(_ profile: UserProfile) {
        if let data = try? encoder.encode(profile) {
            defaults.set(data, forKey: Keys.userProfile)
        }
    }

    func loadProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile) else { return nil }
        return try? decoder.decode(UserProfile.self, from: data)
    }

    // MARK: - Daily Logs

    func saveDailyLogs(_ logs: [String: DailyLog]) {
        if let data = try? encoder.encode(logs) {
            defaults.set(data, forKey: Keys.dailyLogs)
        }
    }

    func loadDailyLogs() -> [String: DailyLog] {
        guard let data = defaults.data(forKey: Keys.dailyLogs) else { return [:] }
        return (try? decoder.decode([String: DailyLog].self, from: data)) ?? [:]
    }

    // MARK: - Flags

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: Keys.notificationsEnabled) }
    }
}
