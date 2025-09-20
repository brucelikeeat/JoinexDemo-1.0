//
//  SignupView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI
import UIKit

struct SignupView: View {
    @State private var showImagePicker = false
    @State private var pendingSource: ImageSourceType = .photoLibrary
    @State private var pickedImage: UIImage? = nil
    @State private var uploadedAvatarURL: String? = nil
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreedToTerms = false
    @State private var showTermsError = false
    @State private var showAlert = false
    
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
                        
                        // Logo
                        Image("logo1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Main heading
                        Text("Create Your Joinex Account")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                        
                        Text("Join our community and start meeting other sport players!")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                        
                        Spacer()
                            .frame(height: 30)
                        
                        // Profile picture section
                        VStack(spacing: 16) {
                            // Profile picture preview or placeholder
                            ZStack {
                                if let image = pickedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.royalBlue)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(username.isEmpty ? "U" : String(username.prefix(1)))
                                                .font(.system(size: 36, weight: .bold, design: .default))
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                            
                            // Upload photo buttons
                            HStack(spacing: 12) {
                                Button(action: { pendingSource = .photoLibrary; showImagePicker = true }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Choose Photo")
                                    }
                                }
                                .foregroundColor(.royalBlue)
                                
                                Button(action: { pendingSource = .camera; showImagePicker = true }) {
                                    HStack {
                                        Image(systemName: "camera")
                                        Text("Take Photo")
                                    }
                                }
                                .foregroundColor(.royalBlue)
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
                                        .foregroundColor(agreedToTerms ? .royalBlue : .gray)
                                        .font(.title3)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("I agree to the Terms of Service and Privacy Policy")
                                        .font(.system(size: 14, weight: .regular, design: .default))
                                        .foregroundColor(.black)
                                }
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
                        AnimatedButton(title: authManager.isLoading ? "Creating Account..." : "Sign Up") {
                            if !agreedToTerms {
                                showTermsError = true
                                return
                            }
                            
                            if password != confirmPassword {
                                authManager.errorMessage = "Passwords do not match"
                                showAlert = true
                                return
                            }
                            
                            if password.count < 6 {
                                authManager.errorMessage = "Password must be at least 6 characters"
                                showAlert = true
                                return
                            }
                            
                            Task {
                                var avatarURL: String? = nil
                                if let img = pickedImage {
                                    avatarURL = await authManager.uploadAvatar(image: img)
                                }
                                let success = await authManager.signUp(email: email, password: password)
                                if success {
                                    // Update profile with chosen username and optional avatar
                                    await _ = authManager.updateProfile(username: username, avatar_url: avatarURL, bio: nil)
                                } else {
                                    showAlert = true
                                }
                            }
                        }
                        .disabled(authManager.isLoading)
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
            .navigationBarHidden(true)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pendingSource) { image in
                    pickedImage = image
                }
            }
            .alert("Signup Error", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(authManager.errorMessage ?? "An error occurred during signup")
            }
        }
    }
}

#Preview {
    SignupView()
        .environmentObject(AuthManager())
} 
 