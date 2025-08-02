//
//  HomeView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    @State private var navigateToEventDetail = false
    @State private var selectedEvent: Event? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all, edges: .top)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        HStack {
                            Image("logo1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good morning!")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                
                                Text(authManager.profile?.username ?? "User")
                                    .font(.system(size: 20, weight: .bold, design: .default))
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
                            Button(action: {
                                selectedTab = 4
                            }) {
                                Circle()
                                    .fill(Color.royalBlue)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text("BL")
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Upcoming Events Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Upcoming Events")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            // Event cards
                            if authManager.userEvents.isEmpty {
                                VStack(spacing: 12) {
                                    Text("No upcoming events")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.gray)
                                        .padding(.vertical, 40)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(authManager.userEvents.prefix(3)) { event in
                                        EventCard(
                                            title: event.title,
                                            date: event.formattedDateTime,
                                            location: event.location,
                                            imageName: "sportscourt",
                                            status: event.isFull ? "Full" : "Open",
                                            statusColor: event.isFull ? .red : .green
                                        ) {
                                            selectedEvent = event
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Recent Activity Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.system(size: 18, weight: .bold, design: .default))
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
                                    iconColor: .royalBlue
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
            }
            .navigationDestination(item: $selectedEvent) { event in
                EventDetailView(event: event)
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await authManager.fetchEvents()
                }
            }
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
        
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(AuthManager())
} 
