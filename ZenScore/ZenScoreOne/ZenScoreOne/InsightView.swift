//
//  InsightView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

// MARK: - Insights Dashboard View
struct InsightView: View {
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
                    
                    // Metrics Analysis Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Metrics Analysis")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            MetricAnalysisCard(
                                iconName: "metrics_analysis_sleep_quality",
                                title: "Sleep Quality",
                                subtitle: "8h 24m",
                                description: "Your deep sleep increased by 18 minutes. Continue maintaining your bedtime routine for optimal recovery."
                            )
                            
                            MetricAnalysisCard(
                                iconName: "metrics_analysis_resting_heart_rate",
                                title: "Resting Heart Rate",
                                subtitle: "54 bpm",
                                description: "Your RHR is trending lower, indicating improved cardiovascular fitness and recovery capacity."
                            )
                            
                            MetricAnalysisCard(
                                iconName: "metrics_analysis_heart_rate_variability",
                                title: "Heart Rate Variability",
                                subtitle: "67 ms",
                                description: "Strong HRV score suggests your nervous system is well-balanced. Great time for training."
                            )
                            
                            MetricAnalysisCard(
                                iconName: "metrics_analysis_activityl_load",
                                title: "Activity Load",
                                subtitle: "Moderate",
                                description: "Your training load is balanced. Consider adding one high-intensity session this week."
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
                            RecommendationCard(
                                iconName: "recommendations_activity_load",
                                title: "Activity Load",
                                description: "Your training load is balanced. Consider adding one high-intensity session this week."
                            )
                            
                            RecommendationCard(
                                iconName: "recommendations_light_strength_training",
                                title: "Light Strength Training",
                                description: "Try a 30-minute resistance workout. Your recovery score indicates you're ready for moderate intensity."
                            )
                            
                            RecommendationCard(
                                iconName: "recommendations_stay_hydrated",
                                title: "Stay Hydrated",
                                description: "Drink at least 2.5L of water today to support cellular recovery and metabolic function."
                            )
                            
                            RecommendationCard(
                                iconName: "recommendations_breath_work_session",
                                title: "Breath-work Session",
                                description: "5 minutes of deep breathing can further enhance your HRV and reduce stress levels."
                            )
                            
                            RecommendationCard(
                                iconName: "recommendations_morning_sunlight",
                                title: "Morning Sunlight",
                                description: "Get 10-15 minutes of natural light exposure to regulate your circadian rhythm and boost energy."
                            )
                        }
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

// MARK: - Metric Analysis Card
struct MetricAnalysisCard: View {
    let iconName: String
    let title: String
    let subtitle: String
    let description: String
    
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
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
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


#Preview {
    InsightView()
}
