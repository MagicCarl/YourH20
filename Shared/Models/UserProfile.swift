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

struct UserProfile: Equatable {
    var weightInPounds: Double
    var heightFeet: Int
    var heightInches: Int
    var sex: BiologicalSex
    var age: Int
    var wakeUpHour: Int
    var wakeUpMinute: Int
    var sleepHour: Int
    var sleepMinute: Int

    var totalHeightInInches: Int {
        heightFeet * 12 + heightInches
    }

    var dailyOunces: Double {
        let base = weightInPounds / 2.0
        // Adjust for age
        let ageFactor: Double
        if age < 30 {
            ageFactor = 1.08
        } else if age < 55 {
            ageFactor = 1.0
        } else {
            ageFactor = 0.92
        }
        // Taller people need more water — add 1 oz per inch above 5'5" (65 in)
        let heightAdjust = Double(max(0, totalHeightInInches - 65))
        return (base * ageFactor) + heightAdjust
    }

    var dailyGlasses: Int {
        Int(ceil(dailyOunces / 8.0))
    }

    /// Total waking minutes between wake-up and bedtime
    var wakingMinutes: Int {
        let wakeTotal = wakeUpHour * 60 + wakeUpMinute
        let sleepTotal = sleepHour * 60 + sleepMinute
        return sleepTotal > wakeTotal ? (sleepTotal - wakeTotal) : (1440 - wakeTotal + sleepTotal)
    }

    static let `default` = UserProfile(
        weightInPounds: 160,
        heightFeet: 5,
        heightInches: 9,
        sex: .male,
        age: 30,
        wakeUpHour: 7,
        wakeUpMinute: 0,
        sleepHour: 22,
        sleepMinute: 0
    )
}

// Backward-compatible Codable: existing saved profiles without minute fields default to 0
extension UserProfile: Codable {
    enum CodingKeys: String, CodingKey {
        case weightInPounds, heightFeet, heightInches, sex, age
        case wakeUpHour, wakeUpMinute, sleepHour, sleepMinute
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        weightInPounds = try c.decode(Double.self, forKey: .weightInPounds)
        heightFeet = try c.decode(Int.self, forKey: .heightFeet)
        heightInches = try c.decode(Int.self, forKey: .heightInches)
        sex = try c.decode(BiologicalSex.self, forKey: .sex)
        age = try c.decode(Int.self, forKey: .age)
        wakeUpHour = try c.decode(Int.self, forKey: .wakeUpHour)
        wakeUpMinute = try c.decodeIfPresent(Int.self, forKey: .wakeUpMinute) ?? 0
        sleepHour = try c.decode(Int.self, forKey: .sleepHour)
        sleepMinute = try c.decodeIfPresent(Int.self, forKey: .sleepMinute) ?? 0
    }
}
