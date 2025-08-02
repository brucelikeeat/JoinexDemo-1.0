//
//  ContentView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    
    var body: some View {
        if authManager.isAuthenticated {
            MainTabView()
                .environmentObject(authManager)
        } else {
            WelcomeView()
                .environmentObject(authManager)
        }
    }
}

#Preview {
    ContentView()
}
