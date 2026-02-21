import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    private let waterType = HKQuantityType(.dietaryWater)

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

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

    // MARK: - Save Water Intake

    func saveWaterIntake(ounces: Double, date: Date = Date()) async -> Bool {
        guard isAvailable else { return false }

        // Convert ounces to fluid ounces (US) for HealthKit
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

    // MARK: - Delete Last Sample

    func deleteLastWaterSample(on date: Date = Date()) async -> Bool {
        guard isAvailable else { return false }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return false
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let sortDescriptor = SortDescriptor(\HKQuantitySample.startDate, order: .reverse)

        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: waterType, predicate: predicate)],
            sortDescriptors: [sortDescriptor],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)
            guard let lastSample = results.first else { return false }
            try await healthStore.delete(lastSample)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Read Today's Total

    func fetchTodayWaterIntake() async -> Double? {
        guard isAvailable else { return nil }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: waterType, predicate: predicate),
            options: .cumulativeSum
        )

        do {
            let result = try await descriptor.result(for: healthStore)
            return result?.sumQuantity()?.doubleValue(for: .fluidOunceUS())
        } catch {
            return nil
        }
    }
}
