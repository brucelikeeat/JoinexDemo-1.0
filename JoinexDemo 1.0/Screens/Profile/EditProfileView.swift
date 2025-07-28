//
//  EditProfileView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName = "Bruce Liu"
    @State private var username = "brucelikeeat"
    @State private var location = "Vancouver, BC, Canada"
    @State private var aboutMe = "Bruce is an active sports lover who plays badminton, tennis, and more. He enjoys meeting new people who share the same passion for staying active and having fun through sports."
    
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
                                .fill(Color.blue)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text("BL")
                                        .font(.system(size: 36, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                            
                            Text("Edit picture or avatar")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.blue)
                        }
                        
                        // Form Fields
                        VStack(spacing: 20) {
                            CustomTextField(
                                label: "Full Name",
                                placeholder: "Enter full name",
                                text: $fullName
                            )
                            
                            CustomTextField(
                                label: "Username",
                                placeholder: "Enter username",
                                text: $username
                            )
                            
                            CustomTextField(
                                label: "Location",
                                placeholder: "Enter location",
                                text: $location,
                                icon: "location"
                            )
                            
                            // About Me
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About Me")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Tell us about yourself")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                
                                TextField("About me...", text: $aboutMe, axis: .vertical)
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
                            AnimatedButton(title: "Save Changes") {
                                dismiss()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    EditProfileView()
} 