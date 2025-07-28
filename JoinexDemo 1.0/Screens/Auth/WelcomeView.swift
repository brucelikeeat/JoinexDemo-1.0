//
//  WelcomeView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct WelcomeView: View {
    @State private var navigateToLogin = false
    @State private var navigateToRegister = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo and App Name
                    VStack(spacing: 20) {
                        JoinixLogo(size: 80)
                        
                        // App Name
                        Text("Joinix")
                            .font(.system(size: 32, weight: .bold, design: .default))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Tagline
                    VStack(spacing: 4) {
                        Text("Find your next match—any sport,")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                        
                        Text("any time.")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Buttons
                    VStack(spacing: 16) {
                        AnimatedButton(title: "Login") {
                            navigateToLogin = true
                        }
                        
                        AnimatedButton(title: "Register", style: .secondary) {
                            navigateToRegister = true
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Footer credit
                    Text("Designed & Developed by Bruce Liu")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                SignupView()
            }
        }
    }
}

#Preview {
    WelcomeView()
} 