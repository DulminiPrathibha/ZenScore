//
//  HomeView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI


// MARK: - Home Dashboard View
struct HomeView: View {
    @StateObject private var healthService = HealthDataService.shared
    
    var body: some View {
        ZStack {
            // Dark background
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            // Main content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Header
                    Text("ZenScore")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    // Recovery Score Circle
                    RecoveryScoreCircle(snapshot: healthService.todaySnapshot)
                        .padding(.vertical, 20)
                    
                    // Metrics Grid
                    MetricsGrid(snapshot: healthService.todaySnapshot)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Recovery Score Circular Progress
struct RecoveryScoreCircle: View {
    let snapshot: DailyHealthSnapshot?
    
    private var recoveryScore: Double {
        snapshot?.recoveryScore ?? 0
    }
    
    private var recoveryPercentage: Double {
        recoveryScore / 100.0
    }
    
    private var recoveryStatus: String {
        snapshot?.recoveryStatus ?? "No Data"
    }
    
    private var recoveryColor: Color {
        if let colorHex = snapshot?.recoveryColor {
            return Color(hex: colorHex)
        }
        return Color.gray
    }
    
    var body: some View {
        ZStack {
            // Outer glow effect
            Circle()
                .stroke(
                    Color(hex: "DF76FF"),
                    lineWidth: 20
                )
                .frame(width: 280, height: 280)
                .blur(radius: 30)
                .opacity(0.7)
            
            // Background circle track
            Circle()
                .stroke(
                    Color(red: 0.2, green: 0.2, blue: 0.2),
                    lineWidth: 20
                )
                .frame(width: 280, height: 280)
            
            // Progress circle (dynamic based on recovery score)
            Circle()
                .trim(from: 0, to: recoveryPercentage)
                .stroke(
                    Color(hex: "DF76FF"),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(hex: "a855f7").opacity(0.6), radius: 25, x: 0, y: 0)
                .animation(.easeInOut(duration: 1.0), value: recoveryPercentage)
            
            // Inner circle background
            Circle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                .frame(width: 220, height: 220)
            
            // Center content
            VStack(spacing: 8) {
                Text("Recovery Score")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text(String(format: "%.0f%%", recoveryScore))
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(recoveryColor)
                    .contentTransition(.numericText())
                
                Text(recoveryStatus)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Metrics Grid
struct MetricsGrid: View {
    let snapshot: DailyHealthSnapshot?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var sleepHours: String {
        if let sleep = snapshot?.sleepDuration {
            let hours = Int(sleep)
            let minutes = Int((sleep - Double(hours)) * 60)
            return "\(hours)h \(minutes)m"
        }
        return "--"
    }
    
    private var restingHR: String {
        if let rhr = snapshot?.restingHeartRate, rhr > 0 {
            return String(format: "%.0f", rhr)
        }
        return "--"
    }
    
    private var hrvValue: String {
        if let hrv = snapshot?.hrv, hrv > 0 {
            return String(format: "%.0f", hrv)
        }
        return "--"
    }
    
    private var activityValue: String {
        if let activity = snapshot?.activityLoad, activity > 0 {
            return String(format: "%.0f", activity)
        }
        return "--"
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            // Sleep Quality Card
            HealthMetricCard(
                iconName: "home_sleep_quality",
                label: "Sleep Duration",
                value: sleepHours,
                valueColor: Color(hex: "60a5fa")
            )
            
            // Resting HR Card
            HealthMetricCard(
                iconName: "home_resting_hr",
                label: "Resting HR",
                value: restingHR,
                valueColor: Color(hex: "ef4444")
            )
            
            // HRV Card
            HealthMetricCard(
                iconName: "home_hrv",
                label: "HRV (SDNN)",
                value: hrvValue,
                valueColor: Color(hex: "22c55e")
            )
            
            // Activity Load Card
            HealthMetricCard(
                iconName: "home_activity_load",
                label: "Activity Load",
                value: activityValue,
                valueColor: Color(hex: "f97316")
            )
        }
    }
}

// MARK: - Health Metric Card Component
struct HealthMetricCard: View {
    let iconName: String
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon from Assets
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            
            // Label
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
            
            // Value
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(valueColor.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    HomeView()
}
