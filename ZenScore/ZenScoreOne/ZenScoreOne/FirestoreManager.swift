//
//  FirestoreManager.swift
//  ZenScoreOne
//
//  Firebase Firestore Database Manager
//

import Foundation
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Save User Profile
    func saveUserProfile(userId: String, name: String, email: String) async throws {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users").document(userId).setData(userData, merge: true)
    }
    
    // MARK: - Get User Profile
    func getUserProfile(userId: String) async throws -> [String: Any]? {
        let document = try await db.collection("users").document(userId).getDocument()
        return document.data()
    }
    
    // MARK: - Save Recovery Score
    func saveRecoveryScore(userId: String, score: Int, sleepQuality: Double, restingHR: Int) async throws {
        let scoreData: [String: Any] = [
            "score": score,
            "sleepQuality": sleepQuality,
            "restingHR": restingHR,
            "timestamp": Timestamp(date: Date())
        ]
        
        try await db.collection("userdata")
            .document(userId)
            .collection("recovery_scores")
            .addDocument(data: scoreData)
    }
    
    // MARK: - Get Recovery Scores
    func getRecoveryScores(userId: String, limit: Int = 30) async throws -> [[String: Any]] {
        let snapshot = try await db.collection("userdata")
            .document(userId)
            .collection("recovery_scores")
            .order(by: "timestamp", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.map { $0.data() }
    }
    
    // MARK: - Save/Update Document
    func saveDocument(collection: String, documentId: String, data: [String: Any]) async throws {
        try await db.collection(collection).document(documentId).setData(data, merge: true)
    }
    
    // MARK: - Get Document
    func getDocument(collection: String, documentId: String) async throws -> [String: Any]? {
        let document = try await db.collection(collection).document(documentId).getDocument()
        return document.data()
    }
    
    // MARK: - Delete Document
    func deleteDocument(collection: String, documentId: String) async throws {
        try await db.collection(collection).document(documentId).delete()
    }
}
