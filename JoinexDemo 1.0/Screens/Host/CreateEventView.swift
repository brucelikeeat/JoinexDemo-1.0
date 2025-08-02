//
//  CreateEventView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct CreateEventView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthManager
    @State private var title = ""
    @State private var sportType = ""
    @State private var location = ""
    @State private var skillLevel: Double = 5
    @State private var playersNeeded = 4
    @State private var additionalNotes = ""
    @State private var isEditingPlayers = false
    @State private var tempPlayersNeeded = ""
    @State private var showSuccessMessage = false
    @State private var isEventCreated = false
    @State private var selectedDate = Date()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
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
                            
                            Text("Create New Event")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
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
                        
                        // Form Fields
                        VStack(spacing: 30) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Event Title")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 15)
                                
                                TextField("Enter event title", text: $title)
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
                                
                                TextField("e.g., Price, court fee split, equipment info, rules...", text: $additionalNotes, axis: .vertical)
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
                            
                            // Create Event Button
                            AnimatedButton(
                                title: isLoading ? "Creating..." : (isEventCreated ? "Event Created!" : "Create Event"),
                                style: isEventCreated ? .success : .primary
                            ) {
                                if !isEventCreated && !isLoading {
                                    Task {
                                        isLoading = true
                                        print("Creating event...")
                                        await createEvent()
                                        isLoading = false
                                        print("Event creation completed")
                                    }
                                }
                            }
                            .disabled(isLoading)
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
                            
                            Text("Event created successfully!")
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
            .alert("Event Creation", isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func createEvent() async {
        print("Starting event creation...")
        
        // Validate required fields
        guard !title.isEmpty else {
            print("Title is empty")
            alertMessage = "Please enter an event title"
            showAlert = true
            return
        }
        
        guard !sportType.isEmpty else {
            print("Sport type is empty")
            alertMessage = "Please select a sport type"
            showAlert = true
            return
        }
        
        guard !location.isEmpty else {
            print("Location is empty")
            alertMessage = "Please enter a location"
            showAlert = true
            return
        }
        
        guard let userId = authManager.currentUser?.id else {
            print("User not authenticated")
            alertMessage = "User not authenticated"
            showAlert = true
            return
        }
        
        let eventRequest = CreateEventRequest(
            title: title,
            description: additionalNotes.isEmpty ? nil : additionalNotes,
            sportType: sportType,
            location: location,
            latitude: nil, // TODO: Add location services
            longitude: nil, // TODO: Add location services
            dateTime: selectedDate,
            durationMinutes: 120, // Default 2 hours
            maxPlayers: playersNeeded,
            skillLevel: Int(skillLevel),
            hostId: userId.uuidString
        )
        
        let success = await authManager.createEvent(eventRequest)
        
        if success {
            alertMessage = "Event created successfully! 🎉"
            isEventCreated = true
        } else {
            alertMessage = authManager.errorMessage ?? "Failed to create event"
        }
        
        showAlert = true
    }
}

#Preview {
    CreateEventView()
        .environmentObject(AuthManager())
} 
 