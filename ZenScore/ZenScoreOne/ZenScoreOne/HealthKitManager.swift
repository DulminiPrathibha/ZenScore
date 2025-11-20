//
//  HealthKitManager.swift
//  ZenScoreOne
//
//  Low-level HealthKit operations
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    private init() {}
    
    // MARK: - Check HealthKit Availability
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Define Health Data Types
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!
    ]
    
    // MARK: - Request Authorization
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, NSError(domain: "HealthKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    // MARK: - Fetch Sleep Data
    func fetchSleepData(range: HealthDataRange, completion: @escaping ([HKCategorySample]) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: range.startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKCategorySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            // Filter for inBed and asleep samples
            let sleepSamples = samples.filter {
                $0.value == HKCategoryValueSleepAnalysis.inBed.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue
            }
            
            DispatchQueue.main.async {
                completion(sleepSamples)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Resting Heart Rate
    func fetchRestingHeartRate(range: HealthDataRange, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let rhrType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: range.startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: rhrType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch HRV (SDNN)
    func fetchHRV(range: HealthDataRange, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: range.startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: hrvType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Active Energy
    func fetchActiveEnergy(range: HealthDataRange, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: range.startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: energyType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Fetch Steps
    func fetchSteps(range: HealthDataRange, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: range.startDate,
            end: Date(),
            options: .strictStartDate
        )
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: stepsType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, results, error in
            guard let samples = results as? [HKQuantitySample], error == nil else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(samples)
            }
        }
        
        healthStore.execute(query)
    }
}