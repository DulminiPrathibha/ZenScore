//
//  HomeView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

// MARK: - Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Home Dashboard View
struct HomeView: View {
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
                    RecoveryScoreCircle()
                        .padding(.vertical, 20)
                    
                    // Metrics Grid
                    MetricsGrid()
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Recovery Score Circular Progress
struct RecoveryScoreCircle: View {
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
            
            // Progress circle (75%)
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    Color(hex: "DF76FF"),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .shadow(color: Color(hex: "a855f7").opacity(0.6), radius: 25, x: 0, y: 0)
            
            // Inner circle background
            Circle()
                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                .frame(width: 220, height: 220)
            
            // Center content
            VStack(spacing: 8) {
                Text("Recovery Score")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                
                Text("75%")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundColor(Color(hex: "10b981"))
                
                Text("Good Recovery")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Metrics Grid
struct MetricsGrid: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            // Sleep Quality Card
            HealthMetricCard(
                iconName: "home_sleep_quality",
                label: "Sleep Quality",
                value: "8.2",
                valueColor: Color(hex: "60a5fa")
            )
            
            // Resting HR Card
            HealthMetricCard(
                iconName: "home_resting_hr",
                label: "Resting HR",
                value: "52",
                valueColor: Color(hex: "ef4444")
            )
            
            // HRV Card
            HealthMetricCard(
                iconName: "home_hrv",
                label: "HRV",
                value: "342",
                valueColor: Color(hex: "22c55e")
            )
            
            // Activity Load Card
            HealthMetricCard(
                iconName: "home_activity_load",
                label: "Activity Load",
                value: "342",
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
