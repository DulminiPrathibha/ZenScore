//
//  ZenScoreOneApp.swift
//  ZenScoreOne
//
//  Created by Supuni Nethsarani on 2025-11-19.
//

import SwiftUI
import FirebaseCore

@main
struct ZenScoreOneApp: App {
    // Initialize Firebase when app launches
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
