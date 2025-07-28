//
//  EditEventView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct EditEventView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sportType = "Road Running"
    @State private var location = "Gastown, Vancouver, V6B 0M6."
    @State private var skillLevel: Double = 5
    @State private var playersNeeded = 200
    @State private var additionalNotes = "Tag on. Hydrate. Snap selfies. Run fierce. Treat yo'self! 💅✨ #GlowAndGo"
    @State private var isEditingPlayers = false
    @State private var tempPlayersNeeded = ""
    @State private var showSuccessMessage = false
    @State private var isEventSaved = false
    
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
                            
                            Circle()
                                .fill(Color.blue)
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
                                Text("Sport Type")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 15)
                                
                                TextField("Select Sport", text: $sportType)
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
                                    .foregroundColor(.blue)
                                
                                Slider(value: $skillLevel, in: 1...10, step: 1)
                                    .accentColor(.blue)
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
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Circle())
                                    }
                                    
                                    Spacer()
                                    
                                    if isEditingPlayers {
                                        TextField("", text: $tempPlayersNeeded)
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
                                            .foregroundColor(.blue)
                                            .frame(width: 32, height: 32)
                                            .background(Color.blue.opacity(0.1))
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
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 100)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSuccessMessage)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    EditEventView()
} 