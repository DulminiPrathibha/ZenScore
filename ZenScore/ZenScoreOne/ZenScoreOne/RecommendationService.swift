//
//  RecommendationService.swift
//  ZenScoreOne
//
//  Generates personalized health recommendations based on user metrics
//

import Foundation

struct Recommendation: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let description: String
    let priority: Int // Higher = more important
}

class RecommendationService {
    static let shared = RecommendationService()
    
    private init() {}
    
    /// Generate personalized recommendations based on weekly data
    func generateRecommendations(from weeklySummary: WeeklySummary) -> [Recommendation] {
        var recommendations: [Recommendation] = []
        
        // Sleep-based recommendations
        if weeklySummary.averageSleep < 7.0 {
            recommendations.append(Recommendation(
                iconName: "recommendations_activity_load",
                title: "Improve Sleep Duration",
                description: "Go to bed 30 minutes earlier to boost recovery. Aim for 7-9 hours per night.",
                priority: 10
            ))
        } else if weeklySummary.averageSleep >= 8.0 {
            recommendations.append(Recommendation(
                iconName: "recommendations_activity_load",
                title: "Excellent Sleep",
                description: "Your sleep duration is optimal. Maintain your current bedtime routine.",
                priority: 5
            ))
        }
        
        // HRV-based recommendations
        if weeklySummary.averageHRV >= 60 {
            recommendations.append(Recommendation(
                iconName: "recommendations_light_strength_training",
                title: "High Intensity Training",
                description: "This is a great day for moderate to high-intensity training. Your HRV indicates good recovery.",
                priority: 8
            ))
        } else if weeklySummary.averageHRV < 40 {
            recommendations.append(Recommendation(
                iconName: "recommendations_breath_work_session",
                title: "Stress Management",
                description: "Consider stress-management or breath-work. Your HRV suggests elevated stress levels.",
                priority: 9
            ))
        }
        
        // RHR-based recommendations
        if weeklySummary.averageRestingHR > 65 {
            recommendations.append(Recommendation(
                iconName: "recommendations_breath_work_session",
                title: "Lower Resting Heart Rate",
                description: "Your RHR is elevated. Try 10 minutes of meditation or deep breathing daily.",
                priority: 8
            ))
        } else if weeklySummary.averageRestingHR < 60 {
            recommendations.append(Recommendation(
                iconName: "recommendations_activity_load",
                title: "Strong Cardiovascular Health",
                description: "Your RHR is trending lower, indicating improved recovery and fitness.",
                priority: 6
            ))
        }
        
        // Activity-based recommendations
        if weeklySummary.averageActivityLoad < 300 {
            recommendations.append(Recommendation(
                iconName: "recommendations_activity_load",
                title: "Increase Activity",
                description: "Aim for at least 5,000 more steps today. Light movement aids recovery.",
                priority: 7
            ))
        } else if weeklySummary.averageActivityLoad > 700 {
            recommendations.append(Recommendation(
                iconName: "recommendations_activity_load",
                title: "Recovery Day Needed",
                description: "Your activity load is high. Consider a rest day or active recovery session.",
                priority: 9
            ))
        } else {
            recommendations.append(Recommendation(
                iconName: "recommendations_light_strength_training",
                title: "Balanced Training Load",
                description: "Try a 30-minute resistance workout. Your recovery score indicates you're ready for moderate intensity.",
                priority: 6
            ))
        }
        
        // General wellness recommendations
        recommendations.append(Recommendation(
            iconName: "recommendations_stay_hydrated",
            title: "Stay Hydrated",
            description: "Drink at least 2.5L of water today to support cellular recovery and metabolic function.",
            priority: 5
        ))
        
        recommendations.append(Recommendation(
            iconName: "recommendations_morning_sunlight",
            title: "Morning Sunlight",
            description: "Get 10-15 minutes of natural light exposure to regulate your circadian rhythm and boost energy.",
            priority: 4
        ))
        
        // Sort by priority (highest first) and return top 6
        return recommendations.sorted { $0.priority > $1.priority }.prefix(6).map { $0 }
    }
    
    /// Generate a single-line insight for a specific metric
    func generateMetricInsight(metric: MetricType, currentValue: Double, previousValue: Double) -> String {
        let percentChange = ((currentValue - previousValue) / max(previousValue, 0.01)) * 100
        
        switch metric {
        case .sleep:
            if percentChange > 5 {
                return "Your sleep improved by \(String(format: "%.1f", percentChange))%. Continue maintaining your bedtime routine for optimal recovery."
            } else if percentChange < -5 {
                return "Your sleep decreased by \(String(format: "%.1f", abs(percentChange)))%. Try going to bed 30 minutes earlier."
            } else {
                return "Your sleep duration is stable. Keep up your current routine."
            }
            
        case .restingHR:
            if currentValue < 60 && currentValue > 0 {
                return "Your RHR is trending lower, indicating improved cardiovascular fitness and recovery capacity."
            } else if currentValue > 70 {
                return "Your RHR is elevated. Consider stress management techniques and adequate rest."
            } else {
                return "Your resting heart rate is in a healthy range."
            }
            
        case .hrv:
            if currentValue >= 60 {
                return "Strong HRV score suggests your nervous system is well-balanced. Great time for training."
            } else if currentValue < 40 {
                return "Lower HRV indicates stress or fatigue. Prioritize recovery and stress management."
            } else {
                return "Your HRV is moderate. Balance training with adequate recovery."
            }
            
        case .activity:
            if currentValue >= 300 && currentValue <= 600 {
                return "Your training load is balanced. This is an optimal activity level for recovery."
            } else if currentValue < 300 {
                return "Your activity is low. Consider adding light movement or a moderate workout."
            } else {
                return "High activity load detected. Ensure you're getting adequate recovery."
            }
        }
    }
    
    enum MetricType {
        case sleep, restingHR, hrv, activity
    }
}
