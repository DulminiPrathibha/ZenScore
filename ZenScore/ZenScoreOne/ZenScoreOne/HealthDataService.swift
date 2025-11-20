//
//  HealthDataService.swift
//  ZenScoreOne
//
//  High-level HealthKit data processing service
//

import Foundation
import HealthKit
import Combine

class HealthDataService: ObservableObject {
    static let shared = HealthDataService()
    
    private let healthKitManager = HealthKitManager.shared
    private let calendar = Calendar.current
    
    @Published var todaySnapshot: DailyHealthSnapshot?
    @Published var weeklySummary: WeeklySummary?
    @Published var monthlySummary: MonthlySummary?
    @Published var twoMonthSummary: TwoMonthSummary?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Request Authorization
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthKitManager.requestAuthorization { success, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
            completion(success)
        }
    }
    
    // MARK: - Get Daily Snapshot
    func getDailySnapshot(date: Date = Date(), completion: @escaping (DailyHealthSnapshot?) -> Void) {
        let group = DispatchGroup()
        
        var sleepDuration: Double = 0
        var restingHR: Double = 0
        var hrv: Double = 0
        var activityLoad: Double = 0
        
        // Fetch sleep data
        group.enter()
        fetchDailySleep(date: date) { duration in
            sleepDuration = duration
            group.leave()
        }
        
        // Fetch RHR
        group.enter()
        fetchDailyRestingHR(date: date) { rhr in
            restingHR = rhr
            group.leave()
        }
        
        // Fetch HRV
        group.enter()
        fetchDailyHRV(date: date) { hrvValue in
            hrv = hrvValue
            group.leave()
        }
        
        // Fetch activity load
        group.enter()
        fetchDailyActivityLoad(date: date) { load in
            activityLoad = load
            group.leave()
        }
        
        group.notify(queue: .main) {
            let snapshot = DailyHealthSnapshot(
                date: date,
                sleepDuration: sleepDuration,
                restingHeartRate: restingHR,
                hrv: hrv,
                activityLoad: activityLoad
            )
            
            if self.calendar.isDateInToday(date) {
                self.todaySnapshot = snapshot
            }
            
            completion(snapshot)
        }
    }
    
    // MARK: - Get Weekly Summary
    func getWeeklySummary(completion: @escaping (WeeklySummary?) -> Void) {
        fetchMultipleDaySnapshots(range: .week) { snapshots in
            let summary = WeeklySummary(snapshots: snapshots)
            self.weeklySummary = summary
            completion(summary)
        }
    }
    
    // MARK: - Get Monthly Summary
    func getMonthlySummary(completion: @escaping (MonthlySummary?) -> Void) {
        fetchMultipleDaySnapshots(range: .month) { snapshots in
            let summary = MonthlySummary(snapshots: snapshots)
            self.monthlySummary = summary
            completion(summary)
        }
    }
    
    // MARK: - Get Two Month Summary
    func getTwoMonthSummary(completion: @escaping (TwoMonthSummary?) -> Void) {
        fetchMultipleDaySnapshots(range: .twoMonths) { snapshots in
            let summary = TwoMonthSummary(snapshots: snapshots)
            self.twoMonthSummary = summary
            completion(summary)
        }
    }
    
    // MARK: - Fetch Multiple Day Snapshots
    private func fetchMultipleDaySnapshots(range: HealthDataRange, completion: @escaping ([DailyHealthSnapshot]) -> Void) {
        let startDate = range.startDate
        let endDate = Date()
        
        var allSnapshots: [DailyHealthSnapshot] = []
        let group = DispatchGroup()
        
        // Generate dates for the range
        var dates: [Date] = []
        var currentDate = startDate
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = self.calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
        }
        
        // Fetch snapshot for each day
        for date in dates {
            group.enter()
            getDailySnapshot(date: date) { snapshot in
                if let snapshot = snapshot {
                    allSnapshots.append(snapshot)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Sort by date
            let sortedSnapshots = allSnapshots.sorted { $0.date < $1.date }
            completion(sortedSnapshots)
        }
    }
    
    // MARK: - Private Helper: Fetch Daily Sleep
    private func fetchDailySleep(date: Date, completion: @escaping (Double) -> Void) {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        healthKitManager.fetchSleepData(range: .day) { samples in
            // Filter samples for the specific day
            let daySamples = samples.filter { sample in
                sample.startDate >= startOfDay && sample.startDate < endOfDay
            }
            
            // Calculate total sleep duration in hours
            var totalSeconds: TimeInterval = 0
            for sample in daySamples {
                totalSeconds += sample.endDate.timeIntervalSince(sample.startDate)
            }
            
            let hours = totalSeconds / 3600.0
            completion(hours)
        }
    }
    
    // MARK: - Private Helper: Fetch Daily Resting HR
    private func fetchDailyRestingHR(date: Date, completion: @escaping (Double) -> Void) {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        healthKitManager.fetchRestingHeartRate(range: .day) { samples in
            // Filter samples for the specific day
            let daySamples = samples.filter { sample in
                sample.startDate >= startOfDay && sample.startDate < endOfDay
            }
            
            // Calculate average
            guard !daySamples.isEmpty else {
                completion(0)
                return
            }
            
            let unit = HKUnit.count().unitDivided(by: .minute())
            let total = daySamples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: unit)
            }
            
            let average = total / Double(daySamples.count)
            completion(average)
        }
    }
    
    // MARK: - Private Helper: Fetch Daily HRV
    private func fetchDailyHRV(date: Date, completion: @escaping (Double) -> Void) {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        healthKitManager.fetchHRV(range: .day) { samples in
            // Filter samples for the specific day
            let daySamples = samples.filter { sample in
                sample.startDate >= startOfDay && sample.startDate < endOfDay
            }
            
            // Calculate average
            guard !daySamples.isEmpty else {
                completion(0)
                return
            }
            
            let unit = HKUnit.secondUnit(with: .milli)
            let total = daySamples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: unit)
            }
            
            let average = total / Double(daySamples.count)
            completion(average)
        }
    }
    
    // MARK: - Private Helper: Fetch Daily Activity Load
    private func fetchDailyActivityLoad(date: Date, completion: @escaping (Double) -> Void) {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let group = DispatchGroup()
        var totalEnergy: Double = 0
        var totalSteps: Double = 0
        
        // Fetch active energy
        group.enter()
        healthKitManager.fetchActiveEnergy(range: .day) { samples in
            // Filter samples for the specific day
            let daySamples = samples.filter { sample in
                sample.startDate >= startOfDay && sample.startDate < endOfDay
            }
            
            let unit = HKUnit.kilocalorie()
            totalEnergy = daySamples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: unit)
            }
            
            group.leave()
        }
        
        // Fetch steps
        group.enter()
        healthKitManager.fetchSteps(range: .day) { samples in
            // Filter samples for the specific day
            let daySamples = samples.filter { sample in
                sample.startDate >= startOfDay && sample.startDate < endOfDay
            }
            
            let unit = HKUnit.count()
            totalSteps = daySamples.reduce(0.0) { sum, sample in
                sum + sample.quantity.doubleValue(for: unit)
            }
            
            group.leave()
        }
        
        group.notify(queue: .main) {
            // Calculate activity load: activeEnergy + (steps * 0.02)
            let activityLoad = totalEnergy + (totalSteps * 0.02)
            completion(activityLoad)
        }
    }
    
    // MARK: - Refresh All Data
    func refreshAllData(completion: @escaping () -> Void) {
        isLoading = true
        let group = DispatchGroup()
        
        // Fetch today's snapshot
        group.enter()
        getDailySnapshot { _ in
            group.leave()
        }
        
        // Fetch weekly summary
        group.enter()
        getWeeklySummary { _ in
            group.leave()
        }
        
        // Fetch monthly summary
        group.enter()
        getMonthlySummary { _ in
            group.leave()
        }
        
        // Fetch two month summary
        group.enter()
        getTwoMonthSummary { _ in
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            completion()
        }
    }
    
    // MARK: - Save to Firebase
    func saveDailySnapshotToFirebase(_ snapshot: DailyHealthSnapshot) async {
        guard let userId = AuthManager().currentUserId else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: snapshot.date)
        
        let data: [String: Any] = [
            "date": dateString,
            "sleepDuration": snapshot.sleepDuration,
            "restingHeartRate": snapshot.restingHeartRate,
            "hrv": snapshot.hrv,
            "activityLoad": snapshot.activityLoad,
            "recoveryScore": snapshot.recoveryScore,
            "timestamp": Date()
        ]
        
        do {
            try await FirestoreManager.shared.saveDocument(
                collection: "userdata/\(userId)/health_snapshots",
                documentId: dateString,
                data: data
            )
        } catch {
            print("Error saving health snapshot: \(error.localizedDescription)")
        }
    }
}
