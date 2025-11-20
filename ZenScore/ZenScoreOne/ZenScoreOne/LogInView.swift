//
//  LogInView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI
import FirebaseAuth

struct LogInView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var navigateToHome = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        ZStack {
            // Dark background
            Color(red: 0.169, green: 0.169, blue: 0.169)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Log In heading
                Text("Log In")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 32)
                
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
                .padding(.bottom, 24)
                
                // Continue button
                Button(action: {
                    handleLogin()
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
                .disabled(isLoading)
                .opacity(isLoading ? 0.6 : 1.0)
                .padding(.bottom, 22)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                        .padding(.bottom, 12)
                }
                
                // Sign Up text
                HStack(spacing: 5) {
                    Text("Don't have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Button(action: {
                        // Navigate to sign up
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.267, blue: 0.4))
                    }
                }
                .padding(.bottom, 20)
                
                // Social login icons
                HStack(spacing: 24) {
                    // Google icon
                    Button(action: {
                        // Google login action
                    }) {
                        Image("google")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                    }
                    
                    // Apple icon
                    Button(action: {
                        // Apple login action
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
        .alert("Log In", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
        }
    }
    
    // MARK: - Login Handler
    private func handleLogin() {
        // Validation
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard !password.isEmpty else {
            showError("Please enter your password")
            return
        }
        
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        // Sign in with Firebase
        isLoading = true
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                
                // Success - navigate to home
                await MainActor.run {
                    isLoading = false
                    navigateToHome = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showError(authManager.errorMessage.isEmpty ? error.localizedDescription : authManager.errorMessage)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    LogInView()
}
