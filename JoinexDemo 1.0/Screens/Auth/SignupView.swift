//
//  SignupView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = "brucelikeeat"
    @State private var email = "brucelikeeat.gmail.com"
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var showTermsError = false
    @State private var navigateToMain = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
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
                            
                            Text("Create Account")
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
                            .frame(height: 40)
                        
                        // Main heading
                        Text("Create Your Minton Account")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Join our community and start meeting other badminton players!")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // Profile picture section
                        VStack(spacing: 16) {
                            // Profile picture placeholder
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 100, height: 100)
                                
                                Text("BL")
                                    .font(.system(size: 36, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            }
                            
                            // Upload photo button
                            Button(action: {
                                // Handle photo upload
                            }) {
                                HStack {
                                    Image(systemName: "camera")
                                        .foregroundColor(.gray)
                                    Text("Upload Photo")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(8)
                            }
                            
                            Text("Optional profile picture for your badminton journey.")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // Input fields
                        VStack(spacing: 20) {
                            CustomTextField(
                                label: "Username",
                                placeholder: "Enter username",
                                text: $username
                            )
                            
                            CustomTextField(
                                label: "Email",
                                placeholder: "Enter email",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            CustomTextField(
                                label: "Password",
                                placeholder: "Enter your password",
                                text: $password,
                                isSecure: true
                            )
                            
                            CustomTextField(
                                label: "Confirm Password",
                                placeholder: "Re-enter your password",
                                text: $confirmPassword,
                                isSecure: true
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Terms agreement
                        VStack(spacing: 8) {
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    agreedToTerms.toggle()
                                    showTermsError = false
                                }) {
                                    Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(agreedToTerms ? .blue : .gray)
                                        .font(.title3)
                                }
                                
                                Text("I agree to the ")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.black) +
                                Text("Terms of Service")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.blue) +
                                Text(" and ")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.black) +
                                Text("Privacy Policy")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.blue)
                            }
                            
                            if showTermsError {
                                Text("You must agree to the Terms of Service.")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // Sign up button
                        AnimatedButton(title: "Sign Up") {
                            if !agreedToTerms {
                                showTermsError = true
                                return
                            }
                            // Handle signup logic here
                            navigateToMain = true
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Footer credit
                        Text("Designed & Developed by Bruce Liu")
                            .font(.system(size: 12, weight: .regular, design: .default))
                            .foregroundColor(.gray.opacity(0.6))
                            .padding(.bottom, 20)
                    }
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
    SignupView()
} 