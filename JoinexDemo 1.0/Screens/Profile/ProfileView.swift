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
                               Image("logo1")
                                   .resizable()
                                   .aspectRatio(contentMode: .fit)
                                   .frame(width: 100, height: 100)
                        
                        Text(authManager.profile?.username ?? "User")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 20)
                        
                        // About Me Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Me")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Text(authManager.profile?.bio ?? "No bio available")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)

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