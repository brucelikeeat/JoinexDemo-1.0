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
    @State private var eventDetails: EventDetails?
    @State private var participants: [EventParticipant] = []
    @State private var isLoading = true
    @State private var lastUpdated = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading event details...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.top, 16)
                    }
                } else {
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
                            
                            if let details = eventDetails {
                                // Event Details Card
                                VStack(alignment: .leading, spacing: 16) {
                                    // Venue
                                    HStack {
                                        Image(systemName: "sportscourt")
                                            .foregroundColor(.royalBlue)
                                            .font(.title3)
                                        
                                        Text(details.title)
                                            .font(.system(size: 16, weight: .medium, design: .default))
                                            .foregroundColor(.black)
                                    }
                                    
                                    // Location
                                    HStack {
                                        Image(systemName: "location")
                                            .foregroundColor(.royalBlue)
                                            .font(.caption)
                                        
                                        Text(details.location)
                                            .font(.system(size: 14, weight: .regular, design: .default))
                                            .foregroundColor(.gray)
                                    }
                                    
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
                                        Image(systemName: "clock.badge")
                                            .foregroundColor(.royalBlue)
                                            .font(.caption)
                                        Text(details.durationText)
                                            .font(.system(size: 14, weight: .regular, design: .default))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Date and Time
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.royalBlue)
                                            .font(.caption)
                                        
                                        Text(details.formattedDate)
                                            .font(.system(size: 14, weight: .regular, design: .default))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.royalBlue)
                                            .font(.caption)
                                        
                                        Text(details.formattedTime)
                                            .font(.system(size: 14, weight: .regular, design: .default))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    // Required Skill
                                    HStack {
                                        Image(systemName: "star")
                                            .foregroundColor(.royalBlue)
                                            .font(.caption)
                                        
                                        Text("Required Skill: \(details.skillLevelText)")
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
                                                Text(details.hostInitials)
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.gray)
                                            )
                                        
                                        Text(details.hostFullName ?? "Unknown Host")
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
                                    
                                    Text(details.description ?? "No description available")
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
                                    
                                    Text("\(details.currentPlayers) / \(details.maxPlayers) Players")
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                    
                                    // Player avatars
                                    HStack(spacing: 8) {
                                        ForEach(participants.prefix(5), id: \.id) { participant in
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Text(participant.initials)
                                                        .font(.system(size: 10, weight: .bold, design: .default))
                                                        .foregroundColor(.gray)
                                                )
                                        }
                                        
                                        // +X indicator if more than 5 participants
                                        if participants.count > 5 {
                                            Circle()
                                                .fill(Color.royalBlue.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                                .overlay(
                                                    Text("+\(participants.count - 5)")
                                                        .font(.system(size: 10, weight: .bold, design: .default))
                                                        .foregroundColor(.royalBlue)
                                                )
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                
                                // Action Buttons
                                VStack(spacing: 12) {
                                    // Join/Leave Button
                                    AnimatedButton(
                                        title: isJoined ? "Event Joined" : "Join Event",
                                        style: isJoined ? .success : .primary
                                    ) {
                                        Task {
                                            do {
                                                if isJoined {
                                                    let success = try await authManager.leaveEventWithSync(eventId: event.id)
                                                    if success {
                                                        isJoined.toggle()
                                                        await refreshData()
                                                    }
                                                } else {
                                                    let success = try await authManager.joinEventWithSync(eventId: event.id)
                                                    if success {
                                                        isJoined.toggle()
                                                        await refreshData()
                                                    }
                                                }
                                            } catch {
                                                print("Error joining/leaving event: \(error)")
                                            }
                                        }
                                    }
                                    
                                    // Message Host Button (only show if not the host)
                                    if details.hostId != authManager.currentUser?.id.uuidString {
                                        Button(action: {
                                            Task {
                                                if let conversation = await authManager.getOrCreateConversation(with: details.hostId) {
                                                    // TODO: Navigate to chat room with this conversation
                                                    print("Created conversation: \(conversation.id)")
                                                }
                                            }
                                        }) {
                                            HStack {
                                                Image(systemName: "message")
                                                    .font(.system(size: 14))
                                                Text("Message Host")
                                                    .font(.system(size: 14, weight: .medium))
                                            }
                                            .foregroundColor(.royalBlue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                            .background(Color.royalBlue.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                                
                                // Last updated indicator
                                HStack {
                                    Spacer()
                                    Text("Last updated: \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                            }
                            
                            Spacer()
                                .frame(height: 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                print("EventDetailView: Loading event with ID: \(event.id)")
                Task {
                    await loadEventDetails()
                    await loadParticipants()
                    await MainActor.run {
                        isLoading = false
                        print("EventDetailView: Loading complete. EventDetails: \(eventDetails != nil), Participants: \(participants.count)")
                    }
                }
            }
            .refreshable {
                await refreshData()
            }
        }
    }
    
    private func loadEventDetails() async {
        do {
            let details = try await authManager.getEventDetails(eventId: event.id)
            await MainActor.run {
                self.eventDetails = details
                self.lastUpdated = Date()
            }
        } catch {
            print("Error loading event details: \(error)")
            // Fallback to using the existing event data
            await MainActor.run {
                self.eventDetails = EventDetails(from: event)
                self.lastUpdated = Date()
            }
        }
    }
    
    private func loadParticipants() async {
        do {
            let participants = try await authManager.getEventParticipants(eventId: event.id)
            await MainActor.run {
                self.participants = participants
                self.lastUpdated = Date()
            }
        } catch {
            print("Error loading participants: \(error)")
            // Fallback to empty participants list
            await MainActor.run {
                self.participants = []
                self.lastUpdated = Date()
            }
        }
        
        // Check if current user is joined
        if let currentUserId = authManager.currentUser?.id.uuidString {
            isJoined = participants.contains { $0.id == currentUserId }
        }
    }
    
    private func refreshData() async {
        await loadEventDetails()
        await loadParticipants()
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
 