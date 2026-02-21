import Foundation

struct WaterEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let ounces: Double

    init(id: UUID = UUID(), timestamp: Date = Date(), ounces: Double = 8.0) {
        self.id = id
        self.timestamp = timestamp
        self.ounces = ounces
    }
}
