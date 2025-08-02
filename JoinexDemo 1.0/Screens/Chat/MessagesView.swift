//
//  MessagesView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct MessagesView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedChat: ChatListItem? = nil
    @State private var chatListItems: [ChatListItem] = []
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all, edges: .top)
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Image("logo1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        
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
                    
                    // Chat List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if chatListItems.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "message")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    Text("No conversations yet")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                    Text("Start chatting with other users!")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .padding(.top, 60)
                            } else {
                                ForEach(chatListItems, id: \.id) { chat in
                                    ChatRow(chat: chat)
                                        .onTapGesture {
                                            selectedChat = chat
                                        }
                                }
                            }
                        }
                        .padding(.top, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedChat) { chat in
                ChatRoomView(chat: chat)
            }
            .onAppear {
                Task {
                    await authManager.fetchConversations()
                    chatListItems = await authManager.getChatListItems()
                }
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
    let chat: ChatListItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            Circle()
                .fill(chat.profileColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(chat.name.prefix(1))
                        .font(.system(size: 18, weight: .bold, design: .default))
                        .foregroundColor(.white)
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
                
                Text(chat.lastMessageText)
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



#Preview {
    MessagesView(selectedTab: .constant(0))
} 