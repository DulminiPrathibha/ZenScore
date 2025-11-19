//
//  ContentView.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // Default view - showing Login screen
        LogInView()
        
        // To preview Sign Up screen instead, uncomment below:
        // SignUpView()
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
