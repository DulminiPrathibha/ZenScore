//
//  SplashScreenView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var opacity = 0.0
    
    var body: some View {
        if isActive {
            // Navigate to login after splash
            LogInView()
        } else {
            ZStack {
                // Dark background
                Color(red: 0.169, green: 0.169, blue: 0.169)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // App icon (Lotus flower)
                    Image("app_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    // App name
                    Text("ZenScore")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
                .opacity(opacity)
            }
            .onAppear {
                // Fade in animation
                withAnimation(.easeIn(duration: 1.0)) {
                    opacity = 1.0
                }
                
                // Navigate to main screen after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
