//
//  EditProfileView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var bio = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
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
                            
                            Text("Edit Profile")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Color.clear
                                .frame(width: 24, height: 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Profile Picture
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Color.royalBlue)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text("BL")
                                        .font(.system(size: 36, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                            
                            Text("Edit picture or avatar")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.royalBlue)
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            CustomTextField(
                                label: "Username",
                                placeholder: "Enter username",
                                text: $username
                            )
                            .padding(.horizontal, 20)
                            
                            // About Me
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About Me")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Tell us about yourself")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                
                                TextField("About me...", text: $bio, axis: .vertical)
                                    .foregroundColor(.black)
                                    .accentColor(.royalBlue)
                                    .tint(.gray.opacity(0.9))
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .lineLimit(4...6)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            
                            // Save Changes Button
                            AnimatedButton(title: isLoading ? "Saving..." : "Save Changes") {
                                Task {
                                    await saveProfile()
                                }
                            }
                            .disabled(isLoading)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                loadProfileData()
            }
            .alert("Profile Update", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func loadProfileData() {
        if let profile = authManager.profile {
            username = profile.username
            bio = profile.bio ?? ""
        }
    }
    
    private func saveProfile() async {
        isLoading = true
        
        let success = await authManager.updateProfile(
            username: username,
            avatar_url: nil,
            bio: bio.isEmpty ? nil : bio
        )
        
        isLoading = false
        
        if success {
            alertMessage = "Profile updated successfully!"
        } else {
            alertMessage = authManager.errorMessage ?? "Failed to update profile"
        }
        
        showAlert = true
    }
}

#Preview {
    EditProfileView()
} 