import Foundation

enum BiologicalSex: String, Codable, CaseIterable, Identifiable {
    case male
    case female

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}

struct UserProfile: Codable, Equatable {
    var weightInPounds: Double
    var sex: BiologicalSex
    var age: Int
    var wakeUpHour: Int
    var sleepHour: Int

    var dailyOunces: Double {
        let base = weightInPounds / 2.0
        // Adjust for age: younger adults need a bit more, older adults a bit less
        let ageFactor: Double
        if age < 30 {
            ageFactor = 1.08
        } else if age < 55 {
            ageFactor = 1.0
        } else {
            ageFactor = 0.92
        }
        return base * ageFactor
    }

    var dailyGlasses: Int {
        Int(ceil(dailyOunces / 8.0))
    }

    var wakingHours: Int {
        sleepHour > wakeUpHour ? (sleepHour - wakeUpHour) : (24 - wakeUpHour + sleepHour)
    }

    static let `default` = UserProfile(
        weightInPounds: 160,
        sex: .male,
        age: 30,
        wakeUpHour: 7,
        sleepHour: 22
    )
}
