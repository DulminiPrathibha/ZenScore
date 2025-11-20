//
//  Trends&Analytics.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

// MARK: - Trends & Analytics Dashboard View
struct TrendsAnalyticsView: View {
    @State private var selectedPeriod: Period = .weekly
    @State private var selectedMetric: MetricType = .sleep
    
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
                        LineChartView(
                            data: [75, 78, 82, 79, 85, 88, 92],
                            labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                            minValue: 70,
                            maxValue: 95,
                            color: Color(hex: "ECA9FF")
                        )
                        .frame(height: 200)
                        .padding(.horizontal, 20)
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
                    
                    // Sleep Duration Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Sleep Duration")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("+12%")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "22c55e"))
                        }
                        .padding(.horizontal, 20)
                        
                        // Sleep Duration Chart
                        LineChartView(
                            data: [6.5, 7.2, 7.8, 7.5, 8.0, 7.6, 8.2],
                            labels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                            minValue: 0,
                            maxValue: 8,
                            color: Color(hex: "ECA9FF")
                        )
                        .frame(height: 200)
                        .padding(.horizontal, 20)
                    }
                    
                    // Summary Statistics Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Summary Statistics")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            SummaryStatCard(icon: "summary_statistics_average_score", label: "Average Score", value: "82.4")
                            SummaryStatCard(icon: "summary_statistics_average_sleep", label: "Average Sleep", value: "82.4")
                            SummaryStatCard(icon: "summary_statistics_peak_activity_day", label: "Peak Activity Day", value: "82.4")
                            SummaryStatCard(icon: "summary_statistics_average_hrv", label: "Average HRV", value: "82.4")
                            SummaryStatCard(icon: "summary_statistics_average_rhr", label: "Average RHR", value: "82.4")
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Weekly Insight Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Weekly Insight")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        WeeklyInsightCard()
                            .padding(.horizontal, 20)
                    }
                    
                    // Bottom padding for tab bar
                    Color.clear
                        .frame(height: 100)
                }
            }
        }
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
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Light bulb icon
            ZStack {
                Circle()
                    .fill(Color(hex: "6C636F"))
                    .frame(width: 48, height: 48)
                
                Image("weekly_insight_great_progress")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text("Great Progress!")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "39FFB6"))
                
                Text("Your recovery score improved by 5.2% this week. Consistent sleep patterns and increased HRV are contributing to better overall recovery.")
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
