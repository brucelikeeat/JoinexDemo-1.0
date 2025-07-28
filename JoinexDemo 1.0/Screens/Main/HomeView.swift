//
//  HomeView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct HomeView: View {
    @State private var navigateToEventDetail = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good morning!")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                
                                Text("brucelikeeat")
                                    .font(.system(size: 24, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            // Notification bell
                            Button(action: {
                                // Handle notifications
                            }) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            
                            // Profile picture
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("BL")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Upcoming Events Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Upcoming Events")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            // Event cards
                            VStack(spacing: 12) {
                                EventCard(
                                    title: "UBC Badminton Centre",
                                    date: "Today, 2:00 PM",
                                    location: "Vancouver, BC",
                                    imageName: "badminton_court_1",
                                    status: "Open",
                                    statusColor: .green
                                ) {
                                    navigateToEventDetail = true
                                }
                                
                                EventCard(
                                    title: "Richmond Ace Badminton",
                                    date: "Tomorrow, 10:00 AM",
                                    location: "Richmond, BC",
                                    imageName: "badminton_court_2",
                                    status: "Full",
                                    statusColor: .red
                                ) {
                                    navigateToEventDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            VStack(spacing: 12) {
                                ActivityCard(
                                    title: "Joined Badminton Session",
                                    subtitle: "UBC Badminton Centre",
                                    time: "2 hours ago",
                                    icon: "checkmark.circle.fill",
                                    iconColor: .green
                                )
                                
                                ActivityCard(
                                    title: "New message from Harrison",
                                    subtitle: "See you in 30 min",
                                    time: "1 hour ago",
                                    icon: "message.fill",
                                    iconColor: .blue
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToEventDetail) {
                EventDetailView()
            }
            .navigationBarHidden(true)
        }
    }
}

struct EventCard: View {
    let title: String
    let date: String
    let location: String
    let imageName: String
    let status: String
    let statusColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Placeholder for event image
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "sportscourt")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(date)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                    
                    Text(location)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Status badge
                Text(status)
                    .font(.system(size: 12, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .cornerRadius(12)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActivityCard: View {
    let title: String
    let subtitle: String
    let time: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(time)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HomeView()
} 