//
//  Trends&Analytics.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

// MARK: - Trends & Analytics Dashboard View
struct TrendsAnalyticsView: View {
    @StateObject private var healthService = HealthDataService.shared
    @State private var selectedPeriod: Period = .weekly
    @State private var selectedMetric: MetricType = .sleep
    @State private var monthlyInsight: String = ""
    
    private let trendService = TrendService.shared
    
    enum Period {
        case weekly, monthly
    }
    
    enum MetricType {
        case sleep, hrv, rhr, activity
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            // Main scrollable content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Trends & Analytics")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    if healthService.isLoading {
                        ProgressView("Loading trends...")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else {
                        // Recovery Score Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Recovery Score")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                // Period Toggle
                                HStack(spacing: 8) {
                                    PeriodButton(title: "Weekly", isSelected: selectedPeriod == .weekly) {
                                        selectedPeriod = .weekly
                                    }
                                    PeriodButton(title: "Monthly", isSelected: selectedPeriod == .monthly) {
                                        selectedPeriod = .monthly
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Recovery Score Chart
                            if let data = getRecoveryScoreData(), !data.isEmpty {
                                LineChartView(
                                    data: data,
                                    labels: getRecoveryScoreLabels(),
                                    minValue: getMinRecoveryScore(data),
                                    maxValue: getMaxRecoveryScore(data),
                                    color: Color(hex: "ECA9FF")
                                )
                                .frame(height: 200)
                                .padding(.horizontal, 20)
                            } else {
                                Text("No data available")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                            }
                        }
                    
                        // Metric Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                MetricTab(icon: "home_sleep_quality", label: "Sleep", isSelected: selectedMetric == .sleep) {
                                    selectedMetric = .sleep
                                }
                                MetricTab(icon: "home_hrv", label: "HRV", isSelected: selectedMetric == .hrv) {
                                    selectedMetric = .hrv
                                }
                                MetricTab(icon: "home_resting_hr", label: "RHR", isSelected: selectedMetric == .rhr) {
                                    selectedMetric = .rhr
                                }
                                MetricTab(icon: "home_activity_load", label: "Activity", isSelected: selectedMetric == .activity) {
                                    selectedMetric = .activity
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Selected Metric Chart Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text(getMetricTitle())
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if let trend = getMetricTrendPercentage() {
                                    Text(trend)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(trend.hasPrefix("+") ? Color(hex: "22c55e") : Color(hex: "ef4444"))
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Metric Chart
                            if let data = getMetricData(), !data.isEmpty {
                                LineChartView(
                                    data: data,
                                    labels: getMetricLabels(),
                                    minValue: 0,
                                    maxValue: getMetricMaxValue(data),
                                    color: Color(hex: "ECA9FF")
                                )
                                .frame(height: 200)
                                .padding(.horizontal, 20)
                            } else {
                                Text("No data available")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200)
                            }
                        }
                    
                        // Summary Statistics Section
                        if let monthly = healthService.monthlySummary {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Summary Statistics")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 12) {
                                    SummaryStatCard(
                                        icon: "summary_statistics_average_score",
                                        label: "Average Score",
                                        value: String(format: "%.1f", monthly.averageRecoveryScore)
                                    )
                                    SummaryStatCard(
                                        icon: "summary_statistics_average_sleep",
                                        label: "Average Sleep",
                                        value: formatSleepValue(monthly.averageSleep)
                                    )
                                    SummaryStatCard(
                                        icon: "summary_statistics_peak_activity_day",
                                        label: "Peak Activity Day",
                                        value: getPeakActivityDay(monthly)
                                    )
                                    SummaryStatCard(
                                        icon: "summary_statistics_average_hrv",
                                        label: "Average HRV",
                                        value: "\(Int(monthly.averageHRV)) ms"
                                    )
                                    SummaryStatCard(
                                        icon: "summary_statistics_average_rhr",
                                        label: "Average RHR",
                                        value: "\(Int(monthly.averageRestingHR)) bpm"
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    
                        // Monthly Insight Section
                        if !monthlyInsight.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Monthly Insight")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                WeeklyInsightCard(insight: monthlyInsight)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Bottom padding for tab bar
                    Color.clear
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
            loadTrends()
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadTrends() {
        healthService.getMonthlySummary { summary in
            if let summary = summary {
                // Generate monthly insight
                self.monthlyInsight = trendService.generateMonthlyInsight(from: summary)
            }
        }
    }
    
    private func getRecoveryScoreData() -> [Double]? {
        if selectedPeriod == .weekly {
            return healthService.weeklySummary?.dailySnapshots.map { $0.recoveryScore }
        } else {
            return healthService.monthlySummary?.dailySnapshots.map { $0.recoveryScore }
        }
    }
    
    private func getRecoveryScoreLabels() -> [String] {
        if selectedPeriod == .weekly {
            if let snapshots = healthService.weeklySummary?.dailySnapshots {
                return trendService.generateDateLabels(for: snapshots, format: .dayOfWeek)
            }
        } else {
            if let snapshots = healthService.monthlySummary?.dailySnapshots {
                // Show every 5th day for monthly view
                let filtered = snapshots.enumerated().filter { $0.offset % 5 == 0 }.map { $0.element }
                return trendService.generateDateLabels(for: filtered, format: .dayOfMonth)
            }
        }
        return []
    }
    
    private func getMinRecoveryScore(_ data: [Double]) -> Double {
        let minVal = data.min() ?? 0
        return max(minVal - 10, 0)
    }
    
    private func getMaxRecoveryScore(_ data: [Double]) -> Double {
        let maxVal = data.max() ?? 100
        return min(maxVal + 10, 100)
    }
    
    private func getMetricData() -> [Double]? {
        let snapshots = selectedPeriod == .weekly ?
            healthService.weeklySummary?.dailySnapshots :
            healthService.monthlySummary?.dailySnapshots
        
        guard let snapshots = snapshots else { return nil }
        
        switch selectedMetric {
        case .sleep:
            return trendService.getMetricTrend(snapshots: snapshots, metric: .sleep)
        case .hrv:
            return trendService.getMetricTrend(snapshots: snapshots, metric: .hrv)
        case .rhr:
            return trendService.getMetricTrend(snapshots: snapshots, metric: .restingHR)
        case .activity:
            return trendService.getMetricTrend(snapshots: snapshots, metric: .activity)
        }
    }
    
    private func getMetricLabels() -> [String] {
        if selectedPeriod == .weekly {
            if let snapshots = healthService.weeklySummary?.dailySnapshots {
                return trendService.generateDateLabels(for: snapshots, format: .dayOfWeek)
            }
        } else {
            if let snapshots = healthService.monthlySummary?.dailySnapshots {
                let filtered = snapshots.enumerated().filter { $0.offset % 5 == 0 }.map { $0.element }
                return trendService.generateDateLabels(for: filtered, format: .dayOfMonth)
            }
        }
        return []
    }
    
    private func getMetricMaxValue(_ data: [Double]) -> Double {
        let maxVal = data.max() ?? 100
        switch selectedMetric {
        case .sleep:
            return max(maxVal + 1, 10)
        case .hrv:
            return max(maxVal + 10, 100)
        case .rhr:
            return max(maxVal + 10, 100)
        case .activity:
            return max(maxVal + 50, 500)
        }
    }
    
    private func getMetricTitle() -> String {
        switch selectedMetric {
        case .sleep: return "Sleep Duration"
        case .hrv: return "Heart Rate Variability"
        case .rhr: return "Resting Heart Rate"
        case .activity: return "Activity Load"
        }
    }
    
    private func getMetricTrendPercentage() -> String? {
        guard let data = getMetricData(), data.count > 1 else { return nil }
        
        let halfPoint = data.count / 2
        let firstHalf = Array(data.prefix(halfPoint))
        let secondHalf = Array(data.suffix(data.count - halfPoint))
        
        guard !firstHalf.isEmpty && !secondHalf.isEmpty else { return nil }
        
        let firstAvg = firstHalf.reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0, +) / Double(secondHalf.count)
        
        let percentChange = ((secondAvg - firstAvg) / max(firstAvg, 0.01)) * 100
        
        if abs(percentChange) < 1 {
            return nil
        }
        
        return String(format: "%+.1f%%", percentChange)
    }
    
    private func formatSleepValue(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
    
    private func getPeakActivityDay(_ monthly: MonthlySummary) -> String {
        guard let peak = monthly.dailySnapshots.max(by: { $0.activityLoad < $1.activityLoad }) else {
            return "--"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: peak.date)
    }
}

// MARK: - Period Toggle Button
struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    Color(hex: "ECA9FF"):
                    Color(red: 0.16, green: 0.16, blue: 0.16)
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color(hex: "a855f7") : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? Color(hex: "a855f7").opacity(0.5) : .clear, radius: 8, x: 0, y: 0)
        }
    }
}

// MARK: - Custom Line Chart
struct LineChartView: View {
    let data: [Double]
    let labels: [String]
    let minValue: Double
    let maxValue: Double
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.16, green: 0.16, blue: 0.16))
                
                VStack(spacing: 0) {
                    // Chart area
                    ZStack(alignment: .bottomLeading) {
                        // Grid lines
                        GridLines(count: 5)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                        
                        // Gradient fill
                        ChartGradientFill(data: data, minValue: minValue, maxValue: maxValue)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0.0)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        // Line path
                        ChartLine(data: data, minValue: minValue, maxValue: maxValue)
                            .stroke(color, lineWidth: 2)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .frame(height: geometry.size.height - 30)
                    
                    // X-axis labels
                    HStack {
                        ForEach(labels, id: \.self) { label in
                            Text(label)
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
        }
    }
}

// MARK: - Chart Line Shape
struct ChartLine: Shape {
    let data: [Double]
    let minValue: Double
    let maxValue: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard data.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(data.count - 1)
        let range = maxValue - minValue
        
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let normalizedValue = (value - minValue) / range
            let y = rect.height - (CGFloat(normalizedValue) * rect.height)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// MARK: - Chart Gradient Fill Shape
struct ChartGradientFill: Shape {
    let data: [Double]
    let minValue: Double
    let maxValue: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard data.count > 1 else { return path }
        
        let stepX = rect.width / CGFloat(data.count - 1)
        let range = maxValue - minValue
        
        // Start from bottom left
        path.move(to: CGPoint(x: 0, y: rect.height))
        
        // Draw line through data points
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * stepX
            let normalizedValue = (value - minValue) / range
            let y = rect.height - (CGFloat(normalizedValue) * rect.height)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Close path at bottom right
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Grid Lines Shape
struct GridLines: Shape {
    let count: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step = rect.height / CGFloat(count)
        
        for i in 0...count {
            let y = CGFloat(i) * step
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        return path
    }
}

// MARK: - Metric Tab
struct MetricTab: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected ?
                Color(hex: "ECA9FF").opacity(0.80):
                Color(red: 0.16, green: 0.16, blue: 0.16)
            )
            .cornerRadius(20)
        }
    }
}

// MARK: - Summary Statistics Card
struct SummaryStatCard: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with purple circular background
            ZStack {
                Circle()
                    .fill(Color(hex: "78607C"))
                    .frame(width: 48, height: 48)
                
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            // Label
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white)
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(16)
    }
}

// MARK: - Weekly Insight Card
struct WeeklyInsightCard: View {
    let insight: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Light bulb icon
            ZStack {
                Circle()
                    .fill(Color(hex: "6C636F"))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "lightbulb.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: "39FFB6"))
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Monthly Progress")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "39FFB6"))
                
                Text(insight)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex: "a855f7").opacity(0.1), Color(hex: "1a1a1a")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "a855f7").opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    TrendsAnalyticsView()
}

