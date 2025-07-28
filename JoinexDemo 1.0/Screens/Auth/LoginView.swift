//
//  LoginView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToMain = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Login")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Placeholder for balance
                        Color.clear
                            .frame(width: 24, height: 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Logo
                    JoinixLogo(size: 60)
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Main heading
                    Text("Login")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Text("Welcome back!")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Input fields
                    VStack(spacing: 20) {
                        CustomTextField(
                            label: "Email",
                            placeholder: "john.doe@example.com",
                            text: $email,
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        CustomTextField(
                            label: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            icon: "lock",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 40)
                    
                    // Login button
                    AnimatedButton(title: "Log in") {
                        // Handle login logic here
                        navigateToMain = true
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Footer credit
                    Text("Designed & Developed by Bruce Liu")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $navigateToMain) {
                MainTabView()
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    LoginView()
} 