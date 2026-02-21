import Foundation

struct DailyLog: Codable, Identifiable, Equatable {
    let id: String
    var entries: [WaterEntry]
    let date: Date

    init(date: Date, entries: [WaterEntry] = []) {
        self.date = Calendar.current.startOfDay(for: date)
        self.id = Self.dateFormatter.string(from: self.date)
        self.entries = entries
    }

    var totalOunces: Double {
        entries.reduce(0) { $0 + $1.ounces }
    }

    var glassesConsumed: Int {
        Int(totalOunces / 8.0)
    }

    func progress(goal: Int) -> Double {
        guard goal > 0 else { return 0 }
        return min(totalOunces / (Double(goal) * 8.0), 1.0)
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
