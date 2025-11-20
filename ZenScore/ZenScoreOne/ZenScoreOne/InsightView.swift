//
//  InsightView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

// MARK: - Insights Dashboard View
struct InsightView: View {
    @StateObject private var healthService = HealthDataService.shared
    @State private var recommendations: [Recommendation] = []
    @State private var weeklyInsight: String = ""
    @State private var previousWeekSummary: WeeklySummary?
    
    private let recommendationService = RecommendationService.shared
    private let trendService = TrendService.shared
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            // Main scrollable content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    Text("Insights")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    if healthService.isLoading {
                        ProgressView("Loading insights...")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 50)
                    } else if let weekly = healthService.weeklySummary {
                        // Metrics Analysis Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Weekly Metrics Analysis")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                // Sleep Analysis
                                MetricAnalysisCard(
                                    iconName: "metrics_analysis_sleep_quality",
                                    title: "Sleep Duration",
                                    subtitle: formatSleepDuration(weekly.averageSleep),
                                    description: getSleepInsight(current: weekly, previous: previousWeekSummary),
                                    trend: weekly.sleepTrend
                                )
                                
                                // Resting Heart Rate Analysis
                                MetricAnalysisCard(
                                    iconName: "metrics_analysis_resting_heart_rate",
                                    title: "Resting Heart Rate",
                                    subtitle: "\(Int(weekly.averageRestingHR)) bpm",
                                    description: getRHRInsight(current: weekly, previous: previousWeekSummary),
                                    trend: weekly.rhrTrend
                                )
                                
                                // HRV Analysis
                                MetricAnalysisCard(
                                    iconName: "metrics_analysis_heart_rate_variability",
                                    title: "Heart Rate Variability",
                                    subtitle: "\(Int(weekly.averageHRV)) ms",
                                    description: getHRVInsight(current: weekly, previous: previousWeekSummary),
                                    trend: weekly.hrvTrend
                                )
                                
                                // Activity Load Analysis
                                MetricAnalysisCard(
                                    iconName: "metrics_analysis_activityl_load",
                                    title: "Activity Load",
                                    subtitle: getActivityLevel(weekly.averageActivityLoad),
                                    description: getActivityInsight(current: weekly, previous: previousWeekSummary),
                                    trend: weekly.activityTrend
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Recommendations Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recommendations")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            
                            VStack(spacing: 12) {
                                ForEach(recommendations) { recommendation in
                                    RecommendationCard(
                                        iconName: recommendation.iconName,
                                        title: recommendation.title,
                                        description: recommendation.description
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Weekly Summary Insight
                        if !weeklyInsight.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Weekly Summary")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                
                                WeeklySummaryCard(insight: weeklyInsight)
                                    .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("No Data Available")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Refresh your health data to see insights")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                    }
                    
                    // Bottom padding for tab bar
                    Color.clear
                        .frame(height: 100)
                }
            }
        }
        .onAppear {
            loadInsights()
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadInsights() {
        // Fetch current week summary
        healthService.getWeeklySummary { summary in
            if let summary = summary {
                // Generate recommendations
                self.recommendations = recommendationService.generateRecommendations(from: summary)
                
                // Fetch previous week for comparison
                healthService.getPreviousWeekSummary { previousSummary in
                    self.previousWeekSummary = previousSummary
                    
                    // Generate weekly insight
                    self.weeklyInsight = trendService.generateWeeklyInsight(
                        from: summary,
                        previousWeekSummary: previousSummary
                    )
                }
            }
        }
    }
    
    private func formatSleepDuration(_ hours: Double) -> String {
        let h = Int(hours)
        let m = Int((hours - Double(h)) * 60)
        return "\(h)h \(m)m"
    }
    
    private func getActivityLevel(_ load: Double) -> String {
        if load < 250 {
            return "Low"
        } else if load < 500 {
            return "Moderate"
        } else {
            return "High"
        }
    }
    
    private func getSleepInsight(current: WeeklySummary, previous: WeeklySummary?) -> String {
        let previousValue = previous?.averageSleep ?? current.averageSleep
        return recommendationService.generateMetricInsight(
            metric: .sleep,
            currentValue: current.averageSleep,
            previousValue: previousValue
        )
    }
    
    private func getRHRInsight(current: WeeklySummary, previous: WeeklySummary?) -> String {
        let previousValue = previous?.averageRestingHR ?? current.averageRestingHR
        return recommendationService.generateMetricInsight(
            metric: .restingHR,
            currentValue: current.averageRestingHR,
            previousValue: previousValue
        )
    }
    
    private func getHRVInsight(current: WeeklySummary, previous: WeeklySummary?) -> String {
        let previousValue = previous?.averageHRV ?? current.averageHRV
        return recommendationService.generateMetricInsight(
            metric: .hrv,
            currentValue: current.averageHRV,
            previousValue: previousValue
        )
    }
    
    private func getActivityInsight(current: WeeklySummary, previous: WeeklySummary?) -> String {
        let previousValue = previous?.averageActivityLoad ?? current.averageActivityLoad
        return recommendationService.generateMetricInsight(
            metric: .activity,
            currentValue: current.averageActivityLoad,
            previousValue: previousValue
        )
    }
}

// MARK: - Metric Analysis Card
struct MetricAnalysisCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let description: String
    var trend: TrendDirection = .stable
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with purple circular background
            ZStack {
                Circle()
                    .fill(Color(hex: "78607C"))
                    .frame(width: 48, height: 48)
                
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Trend indicator
                    Text(trend.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hex: trend.color))
                }
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.7))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(16)
    }
}

// MARK: - Recommendation Cards
struct RecommendationCard: View {
    let iconName: String
    let title: String
    let description: String
    @State private var isDone = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // Icon with purple circular background
                ZStack {
                    Circle()
                        .fill(Color(hex: "3B3B3B"))
                        .frame(width: 48, height: 48)
                    
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Mark as Done Button
            Button(action: {
                isDone.toggle()
            }) {
                Text(isDone ? "Completed" : "Mark as Done")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isDone ? .white : Color(hex: "DF76FF"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        isDone ? Color(hex: "DF76FF") : Color(hex: "9A7CA3").opacity(0.3)
                    )
                    .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "DF76FF").opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Weekly Summary Card
struct WeeklySummaryCard: View {
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
                Text("Weekly Summary")
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
    InsightView()
}
