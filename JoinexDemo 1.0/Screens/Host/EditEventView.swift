//
//  EditEventView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct EditEventView: View {
    @State private var showDateSheet = false
    let event: Event
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var sportType: String
    @State private var location: String
    @State private var skillLevel: Double
    @State private var playersNeeded: Int
    @State private var additionalNotes: String
    @State private var isEditingPlayers = false
    @State private var tempPlayersNeeded = ""
    @State private var showSuccessMessage = false
    @State private var isEventSaved = false
    
    init(event: Event) {
        self.event = event
        self._sportType = State(initialValue: event.sportType)
        self._location = State(initialValue: event.location)
        self._skillLevel = State(initialValue: Double(event.skillLevel))
        self._playersNeeded = State(initialValue: event.maxPlayers)
        self._additionalNotes = State(initialValue: event.description ?? "")
    }
    
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
                            
                            Text("Edit Hosted Event")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            if let urlString = authManager.profile?.avatar_url, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 32, height: 32)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Circle()
                                        .fill(Color.royalBlue)
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Text(String(authManager.profile?.username.prefix(1) ?? "U"))
                                                .font(.system(size: 12, weight: .bold, design: .default))
                                                .foregroundColor(.white)
                                        )
                                }
                            } else {
                                Circle()
                                    .fill(Color.royalBlue)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text(String(authManager.profile?.username.prefix(1) ?? "U"))
                                            .font(.system(size: 12, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                                                    // Form Fields
                            VStack(spacing: 30) {
                                // Date / Time / Duration
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date & Time")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 15)
                                    
                                    Button(action: { showDateSheet = true }) {
                                        HStack(spacing: 16) {
                                            // Icon and main content
                                            HStack(spacing: 12) {
                                                Image(systemName: "calendar.badge.clock")
                                                    .foregroundColor(Color.royalBlue)
                                                    .font(.system(size: 20))
                                                    .frame(width: 24)
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Text(Date(timeIntervalSince1970: event.dateTime.timeIntervalSince1970), style: .date)
                                                            .font(.system(size: 16, weight: .semibold))
                                                            .foregroundColor(.black)
                                                        Spacer()
                                                    }
                                                    
                                                    HStack {
                                                        Text(Date(timeIntervalSince1970: event.dateTime.timeIntervalSince1970), style: .time)
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(.gray)
                                                        Spacer()
                                                    }
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            // Duration badge
                                            VStack(spacing: 2) {
                                                Text("\(event.durationMinutes)")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(Color.royalBlue)
                                                Text("min")
                                                    .font(.system(size: 10, weight: .medium))
                                                    .foregroundColor(Color.royalBlue.opacity(0.8))
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(Color.royalBlue.opacity(0.1))
                                            )
                                            
                                            // Chevron
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14))
                                        }
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 16)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal, 25)
                                }
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Sport Type")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 15)
                                
                                TextField("Select Sport", text: $sportType)
                                    .foregroundColor(.black)
                                    .accentColor(.royalBlue)
                                    .tint(.gray.opacity(0.9))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                    .cornerRadius(12)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 25)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Location")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 15)
                                
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.gray)
                                        .frame(width: 20)
                                    
                                    TextField("Enter venue or address", text: $location)
                                    .foregroundColor(.black)
                                    .accentColor(.royalBlue)
                                    .tint(.gray.opacity(0.9))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 25)
                            }
                            
                            // Skill Level Slider
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Skill Level")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Intermediate (\(Int(skillLevel)))")
                                    .font(.system(size: 16, weight: .bold, design: .default))
                                    .foregroundColor(.royalBlue)
                                
                                Slider(value: $skillLevel, in: 1...10, step: 1)
                                    .accentColor(.royalBlue)
                            }
                            .padding(.horizontal, 20)
                            
                            // Players Needed
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Players Needed")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                HStack {
                                    Button(action: {
                                        if playersNeeded > 1 {
                                            playersNeeded -= 1
                                        }
                                    }) {
                                        Image(systemName: "minus")
                                            .foregroundColor(.royalBlue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.royalBlue.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    
                                    Spacer()
                                    
                                    if isEditingPlayers {
                                        TextField("", text: $tempPlayersNeeded)
                                    .foregroundColor(.black)
                                    .accentColor(.royalBlue)
                                    .tint(.gray.opacity(0.9))
                                            .font(.system(size: 32, weight: .bold, design: .default))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)
                                            .keyboardType(.numberPad)
                                            .onSubmit {
                                                if let newValue = Int(tempPlayersNeeded), newValue > 0 {
                                                    playersNeeded = newValue
                                                }
                                                isEditingPlayers = false
                                            }
                                            .onAppear {
                                                tempPlayersNeeded = "\(playersNeeded)"
                                            }
                                    } else {
                                        Button(action: {
                                            isEditingPlayers = true
                                            tempPlayersNeeded = "\(playersNeeded)"
                                        }) {
                                            Text("\(playersNeeded)")
                                                .font(.system(size: 32, weight: .bold, design: .default))
                                                .foregroundColor(.black)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        playersNeeded += 1
                                    }) {
                                        Image(systemName: "plus")
                                            .foregroundColor(.royalBlue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.royalBlue.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                            .padding(.horizontal, 20)
                            
                            // Additional Notes
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Additional Notes")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                TextField("Enter notes...", text: $additionalNotes, axis: .vertical)
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
                            AnimatedButton(
                                title: isEventSaved ? "Changes Saved!" : "Save Changes",
                                style: isEventSaved ? .success : .primary
                            ) {
                                if !isEventSaved {
                                    // Show success message
                                    showSuccessMessage = true
                                    isEventSaved = true
                                    
                                    // Hide success message after 2 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        showSuccessMessage = false
                                    }
                                    
                                    // Dismiss after 3 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        dismiss()
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
                
                // Success Message Overlay
                if showSuccessMessage {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            
                            Text("Changes saved successfully!")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                        .padding(.horizontal, 40)
                        .padding(.bottom, 100)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccessMessage)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showDateSheet) {
                // Bind to temporary states reflecting current event values
                DateTimeDurationSheet(selectedDate: Binding(get: { event.dateTime }, set: { _ in }), selectedDuration: Binding(get: { event.durationMinutes }, set: { _ in }))
                    .presentationDetents([.height(320)])
            }
        }
    }
}

#Preview {
    EditEventView(
        event: Event(
            id: "preview-event",
            title: "Sample Event",
            description: "Sample description",
            sportType: "Badminton",
            location: "Vancouver",
            latitude: nil,
            longitude: nil,
            dateTime: Date(),
            durationMinutes: 120,
            maxPlayers: 8,
            currentPlayers: 4,
            skillLevel: 5,
            hostId: "preview-host",
            status: .active,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
    .environmentObject(AuthManager())
} 