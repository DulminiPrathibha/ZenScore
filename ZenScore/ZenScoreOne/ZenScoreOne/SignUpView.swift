//
//  SignUpView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.169, green: 0.169, blue: 0.169)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Create Account heading
                Text("Create Account")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
                
                // Name input field
                CustomTextField(
                    text: $name,
                    placeholder: "Name",
                    isFocused: focusedField == .name,
                    isSecure: false
                )
                .focused($focusedField, equals: .name)
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
                
                // Email input field
                CustomTextField(
                    text: $email,
                    placeholder: "Email",
                    isFocused: focusedField == .email,
                    isSecure: false
                )
                .focused($focusedField, equals: .email)
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
                
                // Password input field
                CustomTextField(
                    text: $password,
                    placeholder: "Password",
                    isFocused: focusedField == .password,
                    isSecure: true
                )
                .focused($focusedField, equals: .password)
                .padding(.horizontal, 24)
                .padding(.bottom, 18)
                
                // Confirm Password input field
                CustomTextField(
                    text: $confirmPassword,
                    placeholder: "Confirm Password",
                    isFocused: focusedField == .confirmPassword,
                    isSecure: true
                )
                .focused($focusedField, equals: .confirmPassword)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Continue button
                Button(action: {
                    // Action to be implemented
                }) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.5))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 60)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.847, green: 0.706, blue: 0.996),
                                    Color(red: 0.925, green: 0.694, blue: 0.976)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                }
                .shadow(color: Color(red: 0.847, green: 0.706, blue: 0.996).opacity(0.42), radius: 14, x: 0, y: 0)
                .shadow(color: Color(red: 0.847, green: 0.706, blue: 0.996).opacity(0.28), radius: 21, x: 0, y: 0)
                .padding(.bottom, 22)
                
                // Log In text
                HStack(spacing: 5) {
                    Text("Already have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Button(action: {
                        // Navigate to log in
                    }) {
                        Text("Log in")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.267, blue: 0.4))
                    }
                }
                .padding(.bottom, 20)
                
                // Social login icons
                HStack(spacing: 24) {
                    // Google icon
                    Button(action: {
                        // Google signup action
                    }) {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                    
                    // Apple icon
                    Button(action: {
                        // Apple signup action
                    }) {
                        Image("apple")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
}

#Preview {
    SignUpView()
}
