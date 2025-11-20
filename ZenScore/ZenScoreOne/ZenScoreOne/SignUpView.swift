//
//  SignUpView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @StateObject private var authManager = AuthManager()
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var navigateToLogin = false
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
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
                    handleSignUp()
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
                
                // Log In text
                HStack(spacing: 5) {
                    Text("Already have an account?")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Button(action: {
                        dismiss()
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
        .alert("Sign Up", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $navigateToLogin) {
            LogInView()
        }
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Account created successfully! Please log in with your credentials.")
        }
    }
    
    // MARK: - Sign Up Handler
    private func handleSignUp() {
        // Validation
        guard !name.isEmpty else {
            showError("Please enter your name")
            return
        }
        
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        guard password.count >= 6 else {
            showError("Password must be at least 6 characters")
            return
        }
        
        guard password == confirmPassword else {
            showError("Passwords do not match")
            return
        }
        
        // Sign up with Firebase
        isLoading = true
        Task {
            do {
                try await authManager.signUp(email: email, password: password, name: name)
                
                // Save user profile to Firestore
                if let userId = authManager.currentUserId {
                    try await FirestoreManager.shared.saveUserProfile(
                        userId: userId,
                        name: name,
                        email: email
                    )
                }
                
                // Success - show success message and go back to login
                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
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
    SignUpView()
}
