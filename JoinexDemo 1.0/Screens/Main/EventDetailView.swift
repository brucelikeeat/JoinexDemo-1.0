//
//  EventDetailView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var isJoined = false
    
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
                            
                            Text("Event Details")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
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
                                .fill(Color.royalBlue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("BL")
                                        .font(.system(size: 12, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Event Details Card
                        VStack(alignment: .leading, spacing: 16) {
                            // Venue
                            HStack {
                                Image(systemName: "sportscourt")
                                    .foregroundColor(.royalBlue)
                                    .font(.title3)
                                
                                Text("UBC badminton centre")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                            }
                            
                            // Location
                            HStack {
                                Image(systemName: "location")
                                    .foregroundColor(.royalBlue)
                                    .font(.caption)
                                
                                Text("9151 Van Horne Way, Richmond, BC V6X 1W2, Canada")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            
                            Text("Court 5 - 8")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .padding(.leading, 24)
                            
                            // Event Photo
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Image(systemName: "sportscourt")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 50))
                                )
                            
                            // Date and Time
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.royalBlue)
                                    .font(.caption)
                                
                                Text("Tuesday, July 23, 2024")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.royalBlue)
                                    .font(.caption)
                                
                                Text("9:00 AM - 11:00 AM")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            
                            // Required Skill
                            HStack {
                                Image(systemName: "star")
                                    .foregroundColor(.royalBlue)
                                    .font(.caption)
                                
                                Text("Required Skill: Intermediate (Level 5-7)")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            
                            // Host
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.royalBlue)
                                    .font(.caption)
                                
                                Text("Host:")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                                
                                // Host profile picture
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 24, height: 24)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    )
                                
                                Text("Nick Zhang")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Host Notes Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bubble.left")
                                    .foregroundColor(.royalBlue)
                                    .font(.title3)
                                
                                Text("Host Notes")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                            }
                            
                            Text("Please arrive 15 minutes early for warm-up. Court 5 is located at the far end of the complex. Bring your own racket and water bottle. Parking is available next to the main entrance.")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .lineSpacing(2)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Players Signed Up Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.3")
                                    .foregroundColor(.royalBlue)
                                    .font(.title3)
                                
                                Text("Players Signed Up")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.black)
                            }
                            
                            Text("7 / 8 Players")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.black)
                            
                            // Player avatars
                            HStack(spacing: 8) {
                                ForEach(0..<5, id: \.self) { index in
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text("P\(index + 1)")
                                                .font(.system(size: 10, weight: .bold, design: .default))
                                                .foregroundColor(.gray)
                                        )
                                }
                                
                                // +1 indicator
                                Circle()
                                    .fill(Color.royalBlue.opacity(0.1))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text("+1")
                                            .font(.system(size: 10, weight: .bold, design: .default))
                                            .foregroundColor(.royalBlue)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Join/Leave Button
                        AnimatedButton(
                            title: isJoined ? "Event Joined" : "Join Event",
                            style: isJoined ? .success : .primary
                        ) {
                            isJoined.toggle()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
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
    EventDetailView(
        event: Event(
            id: "preview-event",
            title: "UBC Badminton Centre",
            description: "Join us for a fun badminton session!",
            sportType: "Badminton",
            location: "UBC Badminton Centre, Vancouver",
            latitude: nil,
            longitude: nil,
            dateTime: Date(),
            durationMinutes: 120,
            maxPlayers: 8,
            currentPlayers: 7,
            skillLevel: 5,
            hostId: "preview-host",
            status: .active,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
    .environmentObject(AuthManager())
} 
