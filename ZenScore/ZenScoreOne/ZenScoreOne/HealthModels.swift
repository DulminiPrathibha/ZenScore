//
//  HealthModels.swift
//  ZenScoreOne
//
//  Health data models for ZenScore
//

import Foundation

// MARK: - Date Range Enum
enum HealthDataRange {
    case day
    case week      // 7 days
    case month     // 30 days
    case twoMonths // 60 days
    
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .twoMonths: return 60
        }
    }
    
    var startDate: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }
}

// MARK: - Daily Health Snapshot
struct DailyHealthSnapshot: Identifiable, Codable {
    let id: String
    let date: Date
    var sleepDuration: Double        // in hours
    var restingHeartRate: Double     // bpm
    var hrv: Double                  // SDNN in milliseconds
    var activityLoad: Double         // calculated from energy + steps
    var recoveryScore: Double        // 0-100
    
    init(date: Date,
         sleepDuration: Double = 0,
         restingHeartRate: Double = 0,
         hrv: Double = 0,
         activityLoad: Double = 0) {
        self.id = UUID().uuidString
        self.date = date
        self.sleepDuration = sleepDuration
        self.restingHeartRate = restingHeartRate
        self.hrv = hrv
        self.activityLoad = activityLoad
        self.recoveryScore = DailyHealthSnapshot.calculateRecoveryScore(
            sleep: sleepDuration,
            rhr: restingHeartRate,
            hrv: hrv,
            activity: activityLoad
        )
    }
    
    // Calculate recovery score based on metrics
    static func calculateRecoveryScore(sleep: Double, rhr: Double, hrv: Double, activity: Double) -> Double {
        // Sleep component (0-25 points)
        let sleepScore = min(sleep / 8.0 * 25, 25)
        
        // RHR component (0-25 points) - lower is better
        // Assuming optimal RHR is 50-60 bpm
        let rhrScore: Double
        if rhr == 0 {
            rhrScore = 0
        } else if rhr >= 50 && rhr <= 60 {
            rhrScore = 25
        } else if rhr < 50 {
            rhrScore = max(25 - (50 - rhr) * 0.5, 0)
        } else {
            rhrScore = max(25 - (rhr - 60) * 0.5, 0)
        }
        
        // HRV component (0-30 points) - higher is better
        // Assuming good HRV is 50+ ms
        let hrvScore = min((hrv / 100.0) * 30, 30)
        
        // Activity component (0-20 points)
        // Moderate activity is ideal (300-600 load)
        let activityScore: Double
        if activity >= 300 && activity <= 600 {
            activityScore = 20
        } else if activity < 300 {
            activityScore = (activity / 300.0) * 20
        } else {
            activityScore = max(20 - ((activity - 600) / 100.0) * 2, 0)
        }
        
        let total = sleepScore + rhrScore + hrvScore + activityScore
        return min(max(total, 0), 100)
    }
    
    var recoveryStatus: String {
        switch recoveryScore {
        case 80...100: return "Excellent Recovery"
        case 60..<80: return "Good Recovery"
        case 40..<60: return "Moderate Recovery"
        case 20..<40: return "Poor Recovery"
        default: return "Very Poor Recovery"
        }
    }
    
    var recoveryColor: String {
        switch recoveryScore {
        case 80...100: return "10b981" // Green
        case 60..<80: return "22c55e"  // Light green
        case 40..<60: return "eab308"  // Yellow
        case 20..<40: return "f97316"  // Orange
        default: return "ef4444"       // Red
        }
    }
}

// MARK: - Weekly Summary
struct WeeklySummary: Codable {
    let startDate: Date
    let endDate: Date
    var averageSleep: Double
    var averageRestingHR: Double
    var averageHRV: Double
    var averageActivityLoad: Double
    var averageRecoveryScore: Double
    var dailySnapshots: [DailyHealthSnapshot]
    
    // Trends (compared to previous week)
    var sleepTrend: TrendDirection
    var rhrTrend: TrendDirection
    var hrvTrend: TrendDirection
    var activityTrend: TrendDirection
    
    init(snapshots: [DailyHealthSnapshot]) {
        self.dailySnapshots = snapshots
        
        let calendar = Calendar.current
        self.endDate = Date()
        self.startDate = calendar.date(byAdding: .day, value: -7, to: endDate) ?? endDate
        
        // Calculate averages
        let count = Double(max(snapshots.count, 1))
        self.averageSleep = snapshots.map { $0.sleepDuration }.reduce(0, +) / count
        self.averageRestingHR = snapshots.map { $0.restingHeartRate }.reduce(0, +) / count
        self.averageHRV = snapshots.map { $0.hrv }.reduce(0, +) / count
        self.averageActivityLoad = snapshots.map { $0.activityLoad }.reduce(0, +) / count
        self.averageRecoveryScore = snapshots.map { $0.recoveryScore }.reduce(0, +) / count
        
        // Initialize trends (will be calculated by comparing weeks)
        self.sleepTrend = .stable
        self.rhrTrend = .stable
        self.hrvTrend = .stable
        self.activityTrend = .stable
    }
}

// MARK: - Monthly Summary
struct MonthlySummary: Codable {
    let startDate: Date
    let endDate: Date
    var averageSleep: Double
    var averageRestingHR: Double
    var averageHRV: Double
    var averageActivityLoad: Double
    var averageRecoveryScore: Double
    var weeklySummaries: [WeeklySummary]
    var dailySnapshots: [DailyHealthSnapshot]
    
    // Peak values
    var bestRecoveryDay: DailyHealthSnapshot?
    var worstRecoveryDay: DailyHealthSnapshot?
    var longestSleep: Double
    var shortestSleep: Double
    
    init(snapshots: [DailyHealthSnapshot]) {
        self.dailySnapshots = snapshots
        
        let calendar = Calendar.current
        self.endDate = Date()
        self.startDate = calendar.date(byAdding: .day, value: -30, to: endDate) ?? endDate
        
        // Calculate averages
        let count = Double(max(snapshots.count, 1))
        self.averageSleep = snapshots.map { $0.sleepDuration }.reduce(0, +) / count
        self.averageRestingHR = snapshots.map { $0.restingHeartRate }.reduce(0, +) / count
        self.averageHRV = snapshots.map { $0.hrv }.reduce(0, +) / count
        self.averageActivityLoad = snapshots.map { $0.activityLoad }.reduce(0, +) / count
        self.averageRecoveryScore = snapshots.map { $0.recoveryScore }.reduce(0, +) / count
        
        // Find peak values
        self.bestRecoveryDay = snapshots.max(by: { $0.recoveryScore < $1.recoveryScore })
        self.worstRecoveryDay = snapshots.min(by: { $0.recoveryScore < $1.recoveryScore })
        self.longestSleep = snapshots.map { $0.sleepDuration }.max() ?? 0
        self.shortestSleep = snapshots.map { $0.sleepDuration }.min() ?? 0
        
        // Group into weeks
        self.weeklySummaries = []
        let weeks = stride(from: 0, to: 30, by: 7).map { weekStart -> WeeklySummary in
            let weekSnapshots = snapshots.filter { snapshot in
                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: snapshot.date).day ?? 0
                return daysSinceStart >= weekStart && daysSinceStart < weekStart + 7
            }
            return WeeklySummary(snapshots: weekSnapshots)
        }
        self.weeklySummaries = weeks
    }
}

// MARK: - Two Month Summary (for Trends & Analytics)
struct TwoMonthSummary: Codable {
    let startDate: Date
    let endDate: Date
    var averageSleep: Double
    var averageRestingHR: Double
    var averageHRV: Double
    var averageActivityLoad: Double
    var averageRecoveryScore: Double
    var dailySnapshots: [DailyHealthSnapshot]
    var monthlySummaries: [MonthlySummary]
    
    // Long-term trends
    var overallTrend: TrendDirection
    var sleepTrend: TrendDirection
    var rhrTrend: TrendDirection
    var hrvTrend: TrendDirection
    var activityTrend: TrendDirection
    
    init(snapshots: [DailyHealthSnapshot]) {
        self.dailySnapshots = snapshots
        
        let calendar = Calendar.current
        self.endDate = Date()
        self.startDate = calendar.date(byAdding: .day, value: -60, to: endDate) ?? endDate
        
        // Calculate averages
        let count = Double(max(snapshots.count, 1))
        self.averageSleep = snapshots.map { $0.sleepDuration }.reduce(0, +) / count
        self.averageRestingHR = snapshots.map { $0.restingHeartRate }.reduce(0, +) / count
        self.averageHRV = snapshots.map { $0.hrv }.reduce(0, +) / count
        self.averageActivityLoad = snapshots.map { $0.activityLoad }.reduce(0, +) / count
        self.averageRecoveryScore = snapshots.map { $0.recoveryScore }.reduce(0, +) / count
        
        // Split into two months
        let month1Snapshots = snapshots.filter { snapshot in
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: snapshot.date).day ?? 0
            return daysSinceStart < 30
        }
        let month2Snapshots = snapshots.filter { snapshot in
            let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: snapshot.date).day ?? 0
            return daysSinceStart >= 30
        }
        
        self.monthlySummaries = [
            MonthlySummary(snapshots: month1Snapshots),
            MonthlySummary(snapshots: month2Snapshots)
        ]
        
        // Calculate trends (comparing first 30 days to last 30 days)
        let firstMonthRecovery = month1Snapshots.map { $0.recoveryScore }.reduce(0, +) / Double(max(month1Snapshots.count, 1))
        let secondMonthRecovery = month2Snapshots.map { $0.recoveryScore }.reduce(0, +) / Double(max(month2Snapshots.count, 1))
        
        self.overallTrend = TrendDirection.from(previous: firstMonthRecovery, current: secondMonthRecovery)
        
        // Sleep trend
        let firstMonthSleep = month1Snapshots.map { $0.sleepDuration }.reduce(0, +) / Double(max(month1Snapshots.count, 1))
        let secondMonthSleep = month2Snapshots.map { $0.sleepDuration }.reduce(0, +) / Double(max(month2Snapshots.count, 1))
        self.sleepTrend = TrendDirection.from(previous: firstMonthSleep, current: secondMonthSleep)
        
        // RHR trend (lower is better)
        let firstMonthRHR = month1Snapshots.map { $0.restingHeartRate }.reduce(0, +) / Double(max(month1Snapshots.count, 1))
        let secondMonthRHR = month2Snapshots.map { $0.restingHeartRate }.reduce(0, +) / Double(max(month2Snapshots.count, 1))
        self.rhrTrend = TrendDirection.from(previous: firstMonthRHR, current: secondMonthRHR, lowerIsBetter: true)
        
        // HRV trend
        let firstMonthHRV = month1Snapshots.map { $0.hrv }.reduce(0, +) / Double(max(month1Snapshots.count, 1))
        let secondMonthHRV = month2Snapshots.map { $0.hrv }.reduce(0, +) / Double(max(month2Snapshots.count, 1))
        self.hrvTrend = TrendDirection.from(previous: firstMonthHRV, current: secondMonthHRV)
        
        // Activity trend
        let firstMonthActivity = month1Snapshots.map { $0.activityLoad }.reduce(0, +) / Double(max(month1Snapshots.count, 1))
        let secondMonthActivity = month2Snapshots.map { $0.activityLoad }.reduce(0, +) / Double(max(month2Snapshots.count, 1))
        self.activityTrend = TrendDirection.from(previous: firstMonthActivity, current: secondMonthActivity)
    }
}

// MARK: - Trend Direction
enum TrendDirection: String, Codable {
    case increasing = "↑"
    case decreasing = "↓"
    case stable = "→"
    
    static func from(previous: Double, current: Double, lowerIsBetter: Bool = false) -> TrendDirection {
        let threshold = 0.05 // 5% change threshold
        let percentChange = abs(current - previous) / max(previous, 0.01)
        
        if percentChange < threshold {
            return .stable
        }
        
        if lowerIsBetter {
            return current < previous ? .increasing : .decreasing
        } else {
            return current > previous ? .increasing : .decreasing
        }
    }
    
    var color: String {
        switch self {
        case .increasing: return "22c55e" // Green
        case .decreasing: return "ef4444" // Red
        case .stable: return "eab308"     // Yellow
        }
    }
}