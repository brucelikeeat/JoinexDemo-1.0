//
//  HostView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct HostView: View {
    @Binding var selectedTab: Int
    @State private var navigateToCreateEvent = false
    @State private var navigateToEditEvent = false
    @State private var showCancelAlert = false
    @State private var eventToCancel: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Host")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: {
                            selectedTab = 4
                        }) {
                            Circle()
                                .fill(Color.blue)
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
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Hosted Events Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Hosted Events")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                
                                // Event cards
                                VStack(spacing: 12) {
                                    HostedEventCard(
                                        title: "Charity Run 5K",
                                        date: "Sep 25, 2025",
                                        location: "Gastown, Vancouver",
                                        imageName: "charity_run",
                                        status: "hosting",
                                        statusColor: .orange,
                                        playersCount: 45,
                                        maxPlayers: 200,
                                        canCancel: true,
                                        onCancel: { eventToCancel = "Charity Run 5K"; showCancelAlert = true },
                                        action: { navigateToEditEvent = true }
                                    )
                                    
                                    HostedEventCard(
                                        title: "Community Basketball",
                                        date: "Sep 23, 2025",
                                        location: "Local Gym Arena",
                                        imageName: "basketball",
                                        status: "attending",
                                        statusColor: .green,
                                        playersCount: 8,
                                        maxPlayers: 10,
                                        canCancel: false,
                                        onCancel: {},
                                        action: { navigateToEditEvent = true }
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            // Statistics Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Hosting Statistics")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                HStack(spacing: 16) {
                                    StatCard(title: "Events Hosted", value: "12", icon: "calendar", color: .blue)
                                    StatCard(title: "Total Players", value: "156", icon: "person.3", color: .green)
                                    StatCard(title: "Avg. Rating", value: "4.8", icon: "star", color: .orange)
                                }
                                .padding(.horizontal, 20)
                            }
                            Spacer().frame(height: 80)
                        }
                    }
                    // Create Event Button at the bottom
                    VStack {
                        Spacer()
                        AnimatedButton(title: "Create New Event") {
                            navigateToCreateEvent = true
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                .alert(isPresented: $showCancelAlert) {
                    Alert(
                        title: Text("Cancel Event"),
                        message: Text("Are you sure you want to cancel \(eventToCancel ?? "this event")? This action cannot be undone."),
                        primaryButton: .destructive(Text("Cancel Event")) {
                            // TODO: Integrate cancel logic
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToCreateEvent) {
                CreateEventView()
            }
            .navigationDestination(isPresented: $navigateToEditEvent) {
                EditEventView()
            }
            .navigationBarHidden(true)
        }
    }
}

struct HostedEventCard: View {
    let title: String
    let date: String
    let location: String
    let imageName: String
    let status: String
    let statusColor: Color
    let playersCount: Int
    let maxPlayers: Int
    let canCancel: Bool
    let onCancel: () -> Void
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack(spacing: 12) {
                    // Event image
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
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(date)
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Image(systemName: "location")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text(location)
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Image(systemName: "person.2")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(playersCount) / \(maxPlayers) players")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
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
            if canCancel {
                Button(action: onCancel) {
                    Text("Cancel Event")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
                .background(Color.red.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 8)
                .padding(.top, 4)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .default))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HostView(selectedTab: .constant(0))
} 
