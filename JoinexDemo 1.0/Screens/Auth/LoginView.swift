//
//  LoginView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    
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
                                
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Logo
                    Image("logo1")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                    
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
                    AnimatedButton(title: authManager.isLoading ? "Signing in..." : "Log in") {
                        Task {
                            let success = await authManager.signIn(email: email, password: password)
                            if !success {
                                showAlert = true
                            }
                        }
                    }
                    .disabled(authManager.isLoading)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Footer credit
                    Text("Designed & Developed by Bruce Liu")
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.bottom, 20)
                }
            }
            .navigationBarHidden(true)
            .alert("Login Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(authManager.errorMessage ?? "An error occurred during login")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
} 
