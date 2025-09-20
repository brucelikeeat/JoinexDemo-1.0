//
//  ContentView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authManager = AuthManager()
    @State private var isCheckingSession = true
    @State private var sessionCheckComplete = false
    
    var body: some View {
        Group {
            if isCheckingSession {
                // Loading screen while checking session
                SessionCheckView()
            } else if authManager.isAuthenticated {
                // User is authenticated, show main app
                MainTabView()
                    .environmentObject(authManager)
            } else {
                // User is not authenticated, show welcome screen
                WelcomeView()
                    .environmentObject(authManager)
            }
        }
        .onAppear {
            performSessionCheck()
        }
    }
    
    // MARK: - Session Check Algorithm
    private func performSessionCheck() {
        print("🔍 Starting automatic session check...")
        
        Task {
            // Step 1: Check if user has existing session
            await checkExistingSession()
            
            // Step 2: Validate session if exists
            if authManager.isAuthenticated {
                await validateCurrentSession()
            }
            
            // Step 3: Complete session check
            await MainActor.run {
                isCheckingSession = false
                sessionCheckComplete = true
                print("✅ Session check completed. User authenticated: \(authManager.isAuthenticated)")
            }
        }
    }
    
    // Step 1: Check for existing session
    private func checkExistingSession() async {
        print("📱 Checking for existing user session...")
        
        // Use AuthManager's session checking method
        let hasValidSession = await authManager.checkSession()
        
        if hasValidSession {
            print("👤 Found existing user session")
            await MainActor.run {
                authManager.isAuthenticated = true
            }
        } else {
            print("❌ No existing session found")
            await MainActor.run {
                authManager.isAuthenticated = false
                authManager.currentUser = nil
            }
        }
    }
    
    // Step 2: Validate current session
    private func validateCurrentSession() async {
        print("🔐 Validating current session...")
        
        // Re-check session to ensure it's still valid
        let hasValidSession = await authManager.checkSession()
        
        if hasValidSession {
            print("✅ Session validated successfully")
            await MainActor.run {
                authManager.isAuthenticated = true
            }
        } else {
            print("❌ Session validation failed")
            await MainActor.run {
                authManager.isAuthenticated = false
                authManager.currentUser = nil
            }
        }
    }
}

// MARK: - Session Check Loading View
struct SessionCheckView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background
            Color.royalBlue
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Logo/Icon
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                
                // App Name
                Text("Joinex")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
                
                // Loading Text
                Text("Checking your session...")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.8))
                
                // Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ContentView()
}
