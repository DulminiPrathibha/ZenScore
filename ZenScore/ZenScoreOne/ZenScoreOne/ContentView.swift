//
//  ContentView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthService = HealthDataService.shared
    @State private var selectedTab = 0
    @State private var showHealthKitPermission = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content area
                Group {
                    switch selectedTab {
                    case 0:
                        HomeView()
                    case 1:
                        TrendsAnalyticsView()
                    case 2:
                        InsightView()
                    case 3:
                        ProfilePlaceholderView()
                    default:
                        HomeView()
                    }
                }
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            requestHealthKitPermission()
        }
        .alert("HealthKit Permission", isPresented: $showHealthKitPermission) {
            Button("Allow") {
                requestHealthKitAccess()
            }
            Button("Not Now", role: .cancel) { }
        } message: {
            Text("ZenScore needs access to your health data to calculate your recovery score and provide personalized insights.")
        }
    }
    
    private func requestHealthKitPermission() {
        // Check if HealthKit is available
        guard HealthKitManager.shared.isHealthKitAvailable else {
            print("HealthKit is not available on this device")
            return
        }
        
        // Request permission
        showHealthKitPermission = true
    }
    
    private func requestHealthKitAccess() {
        healthService.requestAuthorization { success in
            if success {
                print("HealthKit authorization granted")
                // Fetch initial data
                healthService.refreshAllData {
                    print("Initial health data loaded")
                }
            } else {
                print("HealthKit authorization denied")
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            CustomTabBarItem(
                iconName: selectedTab == 0 ? "navbar_active_icon1_home" : "navbar_not_active_icon1_home",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            )
            
            // Trends Tab
            CustomTabBarItem(
                iconName: selectedTab == 1 ? "navbar_active_icon2_trends&analytics" : "navbar_not_active_icon2_trends&analytics",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            )
            
            // Insights Tab
            CustomTabBarItem(
                iconName: selectedTab == 2 ? "navbar_active_icon3_insights" : "navbar_not_active_icon3_insights",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            )
            
            // Profile Tab
            CustomTabBarItem(
                iconName: selectedTab == 3 ? "navbar_active_icon4_profile" : "navbar_not_active_icon4_profile",
                isSelected: selectedTab == 3,
                action: { selectedTab = 3 }
            )
        }
        .padding(.vertical, 12)
        .padding(.bottom, 10)
        .background(Color(hex: "1a1a1a"))
    }
}

// MARK: - Custom Tab Bar Item
struct CustomTabBarItem: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Profile Placeholder View
struct ProfilePlaceholderView: View {
    var body: some View {
        ZStack {
            Color(hex: "1a1a1a")
                .ignoresSafeArea()
            
            VStack {
                Text("Profile")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                Text("Coming Soon")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
    }
}

// MARK: - Custom TextField
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let isFocused: Bool
    let isSecure: Bool
    
    var body: some View {
        Group {
            if isSecure {
                SecureField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                TextField("", text: $text)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                    .foregroundColor(.white)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(Color(red: 0.2, green: 0.2, blue: 0.2))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isFocused ? Color.white.opacity(0.5) : Color.white.opacity(0.3),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Placeholder View Modifier
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    ContentView()
}
