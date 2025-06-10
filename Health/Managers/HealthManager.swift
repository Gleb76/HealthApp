import SwiftUI
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? Date()
    }
}

class HealthDataManager {
    static let shared = HealthDataManager()
    
    let healthStore = HKHealthStore()

    private var healthDataTypesToRead: Set<HKObjectType> {
        let quantityTypes: [HKQuantityType] = [
            .activeEnergyBurned,
            .appleExerciseTime,
            .stepCount,
            .appleMoveTime,
            .distanceWalkingRunning,
            .distanceCycling,
            .distanceSwimming,
            .bodyFatPercentage,
            .bodyMass,
            .bodyMassIndex,
            .walkingSpeed
        ].compactMap { HKQuantityType($0) }
        
        let categoryTypes: [HKCategoryType] = [
            .appleStandHour
        ].compactMap { HKCategoryType($0) }
        
        return Set(quantityTypes + categoryTypes)
    }
    
    private init() {
        requestHealthKitAuthorization()
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        Task {
            do {
                try await healthStore.requestAuthorization(
                    toShare: [],
                    read: healthDataTypesToRead
                )
            } catch {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchTodayCaloriesBurned(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let caloriesType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(.failure(HealthKitError.invalidType))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: .startOfDay,
            end: .endOfDay,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: caloriesType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(.success(0))
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            completion(.success(calories))
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayExerciseTime(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(.failure(HealthKitError.invalidType))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: .startOfDay,
            end: .endOfDay,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: exerciseTimeType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(.success(0))
                return
            }
            
            let exerciseTime = sum.doubleValue(for: HKUnit.second())
            completion(.success(exerciseTime))
        }
        
        healthStore.execute(query)
    }
    
    func fetchTodayStandHours(completion: @escaping (Result<Double, Error>) -> Void) {
        guard let standHoursType = HKCategoryType.categoryType(forIdentifier: .appleStandHour) else {
            completion(.failure(HealthKitError.invalidType))
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: .startOfDay,
            end: .endOfDay,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: standHoursType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { _, samples, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let samples = samples as? [HKCategorySample] else {
                completion(.success(0))
                return
            }
            
            let standHours = samples.filter {
                $0.value == HKCategoryValueAppleStandHour.stood.rawValue
            }.count
            
            completion(.success(Double(standHours)))
        }
        
        healthStore.execute(query)
    }
}

enum HealthKitError: Error {
    case invalidType
    case noDataAvailable
    case authorizationDenied
}
