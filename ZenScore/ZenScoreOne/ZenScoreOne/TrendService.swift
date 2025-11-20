//
//  TrendService.swift
//  ZenScoreOne
//
//  Computes trends and generates insights from health data
//

import Foundation

class TrendService {
    static let shared = TrendService()
    
    private init() {}
    
    // MARK: - Weekly Insights
    
    /// Generate a comprehensive weekly insight summary
    func generateWeeklyInsight(from weeklySummary: WeeklySummary, previousWeekSummary: WeeklySummary?) -> String {
        let avgScore = weeklySummary.averageRecoveryScore
        
        var insights: [String] = []
        
        // Recovery score trend
        if let previousWeek = previousWeekSummary {
            let scoreChange = ((avgScore - previousWeek.averageRecoveryScore) / max(previousWeek.averageRecoveryScore, 0.01)) * 100
            
            if scoreChange > 3 {
                insights.append("Your recovery score improved by \(String(format: "%.1f", scoreChange))% this week.")
            } else if scoreChange < -3 {
                insights.append("Your recovery score decreased by \(String(format: "%.1f", abs(scoreChange)))% this week.")
            } else {
                insights.append("Your recovery score remained stable this week.")
            }
        } else {
            insights.append("Your average recovery score this week is \(String(format: "%.1f", avgScore)).")
        }
        
        // Best metric
        let bestMetric = identifyBestMetric(weeklySummary)
        insights.append(bestMetric)
        
        // Weakest metric
        let weakestMetric = identifyWeakestMetric(weeklySummary)
        if !weakestMetric.isEmpty {
            insights.append(weakestMetric)
        }
        
        // Overall trend direction
        let trendDirection = determineTrendDirection(weeklySummary, previousWeekSummary)
        insights.append("Overall, your wellness is \(trendDirection).")
        
        return insights.joined(separator: " ")
    }
    
    /// Generate a monthly insight summary
    func generateMonthlyInsight(from monthlySummary: MonthlySummary) -> String {
        var insights: [String] = []
        
        // Split month into two halves
        let calendar = Calendar.current
        let halfwayPoint = calendar.date(byAdding: .day, value: 15, to: monthlySummary.startDate) ?? monthlySummary.startDate
        
        let firstHalf = monthlySummary.dailySnapshots.filter { $0.date < halfwayPoint }
        let secondHalf = monthlySummary.dailySnapshots.filter { $0.date >= halfwayPoint }
        
        guard !firstHalf.isEmpty && !secondHalf.isEmpty else {
            return "Insufficient data for monthly analysis."
        }
        
        let firstHalfAvgScore = firstHalf.map { $0.recoveryScore }.reduce(0, +) / Double(firstHalf.count)
        let secondHalfAvgScore = secondHalf.map { $0.recoveryScore }.reduce(0, +) / Double(secondHalf.count)
        
        let percentChange = ((secondHalfAvgScore - firstHalfAvgScore) / max(firstHalfAvgScore, 0.01)) * 100
        
        if percentChange > 5 {
            insights.append("Your recovery score improved by \(String(format: "%.1f", percentChange))% this month.")
        } else if percentChange < -5 {
            insights.append("Your recovery score decreased by \(String(format: "%.1f", abs(percentChange)))% this month.")
        } else {
            insights.append("Your recovery score remained consistent this month.")
        }
        
        // Contributing factors
        var factors: [String] = []
        
        // Sleep analysis
        let firstHalfSleep = firstHalf.map { $0.sleepDuration }.reduce(0, +) / Double(firstHalf.count)
        let secondHalfSleep = secondHalf.map { $0.sleepDuration }.reduce(0, +) / Double(secondHalf.count)
        if secondHalfSleep > firstHalfSleep + 0.3 {
            factors.append("consistent sleep patterns")
        }
        
        // HRV analysis
        let firstHalfHRV = firstHalf.map { $0.hrv }.reduce(0, +) / Double(firstHalf.count)
        let secondHalfHRV = secondHalf.map { $0.hrv }.reduce(0, +) / Double(secondHalf.count)
        if secondHalfHRV > firstHalfHRV + 5 {
            factors.append("increased HRV")
        }
        
        // RHR analysis
        let firstHalfRHR = firstHalf.map { $0.restingHeartRate }.reduce(0, +) / Double(firstHalf.count)
        let secondHalfRHR = secondHalf.map { $0.restingHeartRate }.reduce(0, +) / Double(secondHalf.count)
        if secondHalfRHR < firstHalfRHR - 2 {
            factors.append("lower resting heart rate")
        }
        
        if !factors.isEmpty {
            insights.append("\(factors.joined(separator: " and ")) contributed to better overall recovery.")
        }
        
        return insights.joined(separator: " ")
    }
    
    // MARK: - Private Helpers
    
    private func identifyBestMetric(_ summary: WeeklySummary) -> String {
        // Normalize metrics to 0-100 scale for comparison
        let sleepScore = min((summary.averageSleep / 8.0) * 100, 100)
        let hrvScore = min((summary.averageHRV / 100.0) * 100, 100)
        let rhrScore: Double
        if summary.averageRestingHR > 0 {
            rhrScore = max(100 - abs(summary.averageRestingHR - 55) * 2, 0)
        } else {
            rhrScore = 0
        }
        let activityScore = min(max((summary.averageActivityLoad / 500.0) * 100, 0), 100)
        
        let metrics = [
            ("sleep", sleepScore, "sleep duration"),
            ("hrv", hrvScore, "HRV"),
            ("rhr", rhrScore, "resting heart rate"),
            ("activity", activityScore, "activity load")
        ]
        
        if let best = metrics.max(by: { $0.1 < $1.1 }) {
            return "Your best metric this week was \(best.2)."
        }
        
        return "All metrics are balanced."
    }
    
    private func identifyWeakestMetric(_ summary: WeeklySummary) -> String {
        if summary.averageSleep < 6.5 {
            return "Focus on improving sleep duration for better recovery."
        } else if summary.averageHRV < 40 {
            return "Your HRV could be improved with stress management techniques."
        } else if summary.averageRestingHR > 70 {
            return "Consider cardiovascular exercise to lower your resting heart rate."
        } else if summary.averageActivityLoad < 250 {
            return "Increasing daily activity could boost your overall wellness."
        }
        
        return ""
    }
    
    private func determineTrendDirection(_ current: WeeklySummary, _ previous: WeeklySummary?) -> String {
        guard let previous = previous else {
            if current.averageRecoveryScore >= 75 {
                return "excellent"
            } else if current.averageRecoveryScore >= 60 {
                return "good"
            } else {
                return "progressing"
            }
        }
        
        let scoreChange = current.averageRecoveryScore - previous.averageRecoveryScore
        
        if scoreChange > 3 {
            return "improving"
        } else if scoreChange < -3 {
            return "declining"
        } else {
            return "stable"
        }
    }
    
    // MARK: - Trend Data for Charts
    
    /// Extract recovery scores for charting
    func getRecoveryScoreTrend(snapshots: [DailyHealthSnapshot]) -> [Double] {
        return snapshots.map { $0.recoveryScore }
    }
    
    /// Extract metric values for charting
    func getMetricTrend(snapshots: [DailyHealthSnapshot], metric: MetricType) -> [Double] {
        switch metric {
        case .sleep:
            return snapshots.map { $0.sleepDuration }
        case .restingHR:
            return snapshots.map { $0.restingHeartRate }
        case .hrv:
            return snapshots.map { $0.hrv }
        case .activity:
            return snapshots.map { $0.activityLoad }
        }
    }
    
    /// Generate date labels for charts
    func generateDateLabels(for snapshots: [DailyHealthSnapshot], format: DateLabelFormat = .dayOfWeek) -> [String] {
        let formatter = DateFormatter()
        
        switch format {
        case .dayOfWeek:
            formatter.dateFormat = "EEE" // Mon, Tue, Wed
        case .dayOfMonth:
            formatter.dateFormat = "d" // 1, 2, 3
        case .monthDay:
            formatter.dateFormat = "MMM d" // Jan 1, Jan 2
        }
        
        return snapshots.map { formatter.string(from: $0.date) }
    }
    
    enum MetricType {
        case sleep, restingHR, hrv, activity
    }
    
    enum DateLabelFormat {
        case dayOfWeek, dayOfMonth, monthDay
    }
}