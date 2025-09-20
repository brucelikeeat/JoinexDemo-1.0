//
//  ChatRoomView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct MessageRow: View {
    let message: ChatMessage
    @ObservedObject var authManager: AuthManager
    let chat: ChatListItem
    
    var body: some View {
        let isFromUser = message.senderId == authManager.currentUser?.id.uuidString
        let userInitial = isFromUser ?
            String(authManager.profile?.username.prefix(1) ?? "U") :
            String(chat.name.prefix(1))
        let userColor = isFromUser ? Color.green : chat.profileColor
        
        MessageBubble(
            text: message.content,
            isFromUser: isFromUser,
            time: formatMessageTime(message.createdAt),
            userInitial: userInitial,
            userColor: userColor
        )
    }
}

struct ChatRoomView: View {
    let chat: ChatListItem
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var isSending = false
    @State private var showMoreOptions = false
    
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
                                .fill(chat.profileColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(chat.name.prefix(1))
                                        .font(.system(size: 16, weight: .bold, design: .default))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(chat.name)
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                Text("Online")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(.green)
                            }
                        }
                        Spacer()
                        // Call buttons
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "phone")
                                    .font(.title3)
                                    .foregroundColor(.royalBlue)
                            }
                            Button(action: {}) {
                                Image(systemName: "video")
                                    .font(.title3)
                                    .foregroundColor(.royalBlue)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    // Messages
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if authManager.conversationMessages.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "message")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    Text("No messages yet")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.gray)
                                    Text("Start the conversation!")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .padding(.top, 60)
                                                            } else {
                                                            ForEach(authManager.conversationMessages, id: \.id) { message in
                            MessageRow(message: message, authManager: authManager, chat: chat)
                        }
                                }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    // Input bar with foldable menu
                    VStack(spacing: 0) {
                        // Main input bar
                        HStack(spacing: 12) {
                            // More options button (foldable menu trigger)
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showMoreOptions.toggle()
                                }
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                            
                            // Text field (longer)
                            TextField("Aa", text: $messageText)
                                .foregroundColor(.black)
                                .accentColor(.royalBlue)
                                .tint(.gray.opacity(0.9))
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(20)
                            
                            // Send button
                            Button(action: {
                                if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    Task {
                                        isSending = true
                                        let success = await authManager.sendMessage(
                                            content: messageText.trimmingCharacters(in: .whitespacesAndNewlines),
                                            to: chat.conversation.id
                                        )
                                        if success {
                                            messageText = ""
                                        }
                                        isSending = false
                                    }
                                }
                            }) {
                                Image(systemName: isSending ? "clock" : "paperplane")
                                    .font(.title2)
                                    .foregroundColor(isSending ? .gray : .royalBlue)
                            }
                            .disabled(isSending || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        
                        // Foldable options menu
                        if showMoreOptions {
                            HStack(spacing: 20) {
                                Button(action: {
                                    // Photo action
                                    showMoreOptions = false
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.royalBlue)
                                        Text("Photo")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {
                                    // Camera action
                                    showMoreOptions = false
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "camera")
                                            .font(.title2)
                                            .foregroundColor(.royalBlue)
                                        Text("Camera")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {
                                    // Location action
                                    showMoreOptions = false
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "location")
                                            .font(.title2)
                                            .foregroundColor(.royalBlue)
                                        Text("Location")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Button(action: {
                                    // Emoji action
                                    showMoreOptions = false
                                }) {
                                    VStack(spacing: 4) {
                                        Image(systemName: "face.smiling")
                                            .font(.title2)
                                            .foregroundColor(.royalBlue)
                                        Text("Emoji")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                            .background(Color.white)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
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
            .alert("Chat Error", isPresented: .constant(authManager.chatError != nil)) {
                Button("OK") {
                    authManager.chatError = nil
                }
            } message: {
                Text(authManager.chatError ?? "Unknown error")
            }
            .onAppear {
                Task {
                    await authManager.fetchMessages(for: chat.conversation.id)
                }
            }

        }
    }
}



struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let time: String
    // For avatar
    let userInitial: String?
    let userColor: Color?
}

struct MessageBubble: View {
    let text: String
    let isFromUser: Bool
    let time: String
    let userInitial: String?
    let userColor: Color?
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !isFromUser {
                Circle()
                    .fill(userColor ?? .royalBlue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(userInitial ?? "?")
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
                                                .background(isFromUser ? Color.royalBlue : Color.gray.opacity(0.2))
                    .cornerRadius(20)
                Text(time)
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            if isFromUser {
                Circle()
                    .fill(userColor ?? .green)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(userInitial ?? "BL")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing : .leading)
    }
}

// Helper function to format message time
func formatMessageTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
}

#Preview {
    ChatRoomView(chat: ChatListItem(
        id: "sample-chat-item",
        conversation: Conversation(
            id: "sample-conversation",
            user1Id: "user1",
            user2Id: "user2",
            createdAt: Date(),
            updatedAt: Date()
        ),
        otherUser: Profile(
            id: UUID().uuidString,
            username: "John Doe",
            avatar_url: nil,
            bio: "Sports enthusiast",
            created_at: "2024-01-01T00:00:00Z"
        ),
        lastMessage: nil
    ))
    .environmentObject(AuthManager())
} 
 