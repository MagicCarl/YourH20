import Foundation
import HealthKit

final class WatchHealthKitManager {
    static let shared = WatchHealthKitManager()

    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType(.dietaryWater)

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }

        let typesToShare: Set<HKSampleType> = [waterType]
        let typesToRead: Set<HKObjectType> = [waterType]

        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            return true
        } catch {
            return false
        }
    }

    func saveWaterIntake(ounces: Double, date: Date = Date()) async -> Bool {
        guard isAvailable else { return false }

        let quantity = HKQuantity(unit: .fluidOunceUS(), doubleValue: ounces)
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: date,
            end: date
        )

        do {
            try await healthStore.save(sample)
            return true
        } catch {
            return false
        }
    }
}
