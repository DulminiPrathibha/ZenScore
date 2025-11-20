//
//  AuthManager.swift
//  ZenScoreOne
//
//  Firebase Authentication Manager
//

import Foundation
import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        // Listen for authentication state changes
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isAuthenticated = user != nil
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String, name: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Update user profile with name
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            self.user = result.user
            self.errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.user = result.user
            self.errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            self.errorMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Get Current User ID
    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    // MARK: - Get Current User Email
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    // MARK: - Get Current User Display Name
    var currentUserDisplayName: String? {
        return Auth.auth().currentUser?.displayName
    }
}
