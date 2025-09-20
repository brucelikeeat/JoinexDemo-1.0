 //
//  ProfileView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    @State private var navigateToEditProfile = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all, edges: .top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("\(authManager.profile?.username ?? "User")'s Profile")
                                .font(.system(size: 24, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(action: {
                                navigateToEditProfile = true
                            }) {
                                HStack {
                                    Image(systemName: "gear")
                                        .foregroundColor(.blue)
                                    Text("Edit")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Profile Picture
                        if let urlString = authManager.profile?.avatar_url, let url = URL(string: urlString) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.royalBlue.opacity(0.3), lineWidth: 2)
                                    )
                            } placeholder: {
                                Circle()
                                    .fill(Color.royalBlue.opacity(0.1))
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    )
                            }
                        } else {
                            Circle()
                                .fill(Color.royalBlue)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String(authManager.profile?.username.prefix(1) ?? "U"))
                                        .font(.system(size: 36, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        Text(authManager.profile?.username ?? "User")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                        
                        // About Me Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.royalBlue)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text("About Me")
                                    .font(.system(size: 18, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            
                            if let bio = authManager.profile?.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.black)
                                    .lineSpacing(2)
                                    .multilineTextAlignment(.leading)
                            } else {
                                HStack {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    
                                    Text("Add a bio to tell others about yourself")
                                        .font(.system(size: 14, weight: .regular, design: .default))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                        .padding(.horizontal, 20)
                        
                        // Events Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Events hosted/attended")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            // Event cards
                            HStack(spacing: 12) {
                                ProfileEventCard(
                                    title: "Charity Run 5K",
                                    date: "Sep 25, 2025",
                                    location: "Gastown, Vancouver",
                                    status: "hosting",
                                    statusColor: .orange
                                )
                                
                                ProfileEventCard(
                                    title: "Community Basketball",
                                    date: "Sep 23, 2025",
                                    location: "Local Gym Arena",
                                    status: "attending",
                                    statusColor: .green
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                        
                        // Sign Out Button
                        AnimatedButton(title: "Sign Out", style: .secondary) {
                            Task {
                                await authManager.signOut()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToEditProfile) {
                EditProfileView()
                    .environmentObject(authManager)
            }
            .navigationBarHidden(true)
        }
    }
}

struct ProfileEventCard: View {
    let title: String
    let date: String
    let location: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Event image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 80)
                .overlay(
                    Image(systemName: "sportscourt")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .font(.caption2)
                    
                    Text(date)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.blue)
                        .font(.caption2)
                    
                    Text(location)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack {
                    Spacer()
                    
                    Text(status)
                        .font(.system(size: 10, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        
    }
}

#Preview {
    ProfileView(selectedTab: .constant(0))
        .environmentObject(AuthManager())
}