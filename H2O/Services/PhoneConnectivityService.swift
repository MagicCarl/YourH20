import Foundation
import WatchConnectivity
import Combine

final class PhoneConnectivityService: NSObject, ObservableObject {
    static let shared = PhoneConnectivityService()

    let watchDidLogGlass = PassthroughSubject<WaterEntry, Never>()

    private var session: WCSession?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    override init() {
        super.init()
        activateSession()
    }

    private func activateSession() {
        guard WCSession.isSupported() else { return }
        session = WCSession.default
        session?.delegate = self
        session?.activate()
    }

    // MARK: - Send State to Watch

    func sendStateToWatch(profile: UserProfile, dailyLogs: [String: DailyLog]) {
        guard let session, session.isPaired, session.isWatchAppInstalled else { return }

        var context: [String: Any] = [:]

        if let profileData = try? encoder.encode(profile) {
            context["userProfile"] = profileData
        }
        if let logsData = try? encoder.encode(dailyLogs) {
            context["dailyLogs"] = logsData
        }

        try? session.updateApplicationContext(context)
    }

    // MARK: - Handle Watch Messages

    private func handleWatchMessage(_ message: [String: Any]) {
        guard let action = message["action"] as? String, action == "logGlass" else { return }
        guard let entryDict = message["entry"] as? [String: Any] else { return }

        if let jsonData = try? JSONSerialization.data(withJSONObject: entryDict),
           let entry = try? decoder.decode(WaterEntry.self, from: jsonData) {
            watchDidLogGlass.send(entry)
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneConnectivityService: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any]
    ) {
        Task { @MainActor in
            self.handleWatchMessage(message)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveUserInfo userInfo: [String: Any] = [:]
    ) {
        Task { @MainActor in
            self.handleWatchMessage(userInfo)
        }
    }
}
