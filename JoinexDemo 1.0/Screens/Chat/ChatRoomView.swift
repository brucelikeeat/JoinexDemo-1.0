//
//  ChatRoomView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ChatRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
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
                        
                        // Contact info
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("H")
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Harrison Lin")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                
                                Text("Active now")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(.green)
                            }
                        }
                        
                        Spacer()
                        
                        // Call buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                // Handle call
                            }) {
                                Image(systemName: "phone")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                            
                            Button(action: {
                                // Handle video call
                            }) {
                                Image(systemName: "video")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Messages
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Sample messages
                            MessageBubble(
                                text: "See you in 30 min",
                                isFromUser: false,
                                time: "11:59"
                            )
                            
                            MessageBubble(
                                text: "Prepared some donuts for you. Bet you'll love them 😋😋",
                                isFromUser: true,
                                time: "12:01"
                            )
                            
                            MessageBubble(
                                text: "Thats a lot 🎉🎉🎉",
                                isFromUser: false,
                                time: "12:03"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    
                    // Input bar
                    HStack(spacing: 12) {
                        Button(action: {
                            // Handle location
                        }) {
                            Image(systemName: "location")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            // Handle emoji
                        }) {
                            Image(systemName: "face.smiling")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            // Handle image
                        }) {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        TextField("Aa", text: $messageText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        
                        Button(action: {
                            // Handle send
                            messageText = ""
                        }) {
                            Image(systemName: "paperplane")
                                .font(.title3)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.2)),
                        alignment: .top
                    )
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct MessageBubble: View {
    let text: String
    let isFromUser: Bool
    let time: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isFromUser {
                // Other user's profile picture
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("H")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: isFromUser ? .trailing : .leading, spacing: 4) {
                Text(text)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(isFromUser ? .white : .black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(isFromUser ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(20)
                
                Text(time)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            
            if isFromUser {
                // Current user's profile picture
                Circle()
                    .fill(Color.green)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("BL")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
    }
}

#Preview {
    ChatRoomView()
} 