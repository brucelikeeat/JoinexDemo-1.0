 //
//  ProfileView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ProfileView: View {
    @Binding var selectedTab: Int
    @State private var navigateToEditProfile = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Text("brucelikeeat's Profile")
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
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("BL")
                                    .font(.system(size: 36, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            )
                        
                        Text("brucelikeeat")
                            .font(.system(size: 20, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        // About Me Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Me")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Text("I'm an active sports lover who plays badminton, tennis, and more. I enjoys meeting new people who share the same passion for staying active and having fun through sports.")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
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
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToEditProfile) {
                EditProfileView()
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
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ProfileView(selectedTab: .constant(0))
}