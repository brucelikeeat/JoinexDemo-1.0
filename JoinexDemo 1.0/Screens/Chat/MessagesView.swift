//
//  MessagesView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct MessagesView: View {
    @Binding var selectedTab: Int
    @State private var selectedChat: Chat? = nil
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Messages")
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // Notification badge
                        ZStack {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundColor(.black)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                        }
                        
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
                    
                    // Chat List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(sampleChats, id: \.id) { chat in
                                ChatRow(chat: chat)
                                    .onTapGesture {
                                        selectedChat = chat
                                    }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedChat) { chat in
                ChatRoomView(
                    chat: chat,
                    chatHistory: sampleChatHistory(for: chat)
                )
            }
        }
    }
}

// Helper to provide chat history for each chat
func sampleChatHistory(for chat: Chat) -> [Message] {
    switch chat.name {
    case "Harrison Lin":
        return [
            Message(text: "See you in 30 min", isFromUser: false, time: "11:59", userInitial: nil, userColor: nil),
            Message(text: "Prepared some donuts for you. Bet you'll love them 😋😋", isFromUser: true, time: "12:01", userInitial: "BL", userColor: .green),
            Message(text: "Thats a lot 🎉🎉🎉", isFromUser: false, time: "12:03", userInitial: nil, userColor: nil)
        ]
    case "Paul Xu":
        return [
            Message(text: "Great game today!", isFromUser: false, time: "11:45", userInitial: nil, userColor: nil),
            Message(text: "Thanks Paul!", isFromUser: true, time: "11:46", userInitial: "BL", userColor: .green)
        ]
    case "Nick Zhang":
        return [
            Message(text: "Event details updated", isFromUser: false, time: "10:30", userInitial: nil, userColor: nil),
            Message(text: "Got it, thanks!", isFromUser: true, time: "10:31", userInitial: "BL", userColor: .green)
        ]
    default:
        return []
    }
}

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            Circle()
                .fill(chat.profileColor)
                .frame(width: 50, height: 50)
                .overlay(
                    chat.profileImage.isEmpty ?
                        AnyView(
                            Text(chat.name.prefix(1))
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        )
                        :
                        AnyView(
                            Image(systemName: chat.profileImage)
                                .foregroundColor(.white)
                                .font(.title3)
                        )
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.name)
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Text(chat.lastMessageTime)
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                }
                
                Text(chat.lastMessage)
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        
        Divider()
            .padding(.leading, 82)
    }
}

struct Chat: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let lastMessage: String
    let lastMessageTime: String
    let profileColor: Color
    let profileImage: String
    let isActive: Bool
}

let sampleChats = [
    Chat(name: "Harrison Lin", lastMessage: "See you in 30 min", lastMessageTime: "12:03", profileColor: .blue, profileImage: "", isActive: true),
    Chat(name: "Paul Xu", lastMessage: "Great game today!", lastMessageTime: "11:45", profileColor: .green, profileImage: "", isActive: false),
    Chat(name: "Nick Zhang", lastMessage: "Event details updated", lastMessageTime: "10:30", profileColor: .gray, profileImage: "person.fill", isActive: false)
]

#Preview {
    MessagesView(selectedTab: .constant(0))
} 