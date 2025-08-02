//
//  ChatRoomView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ChatRoomView: View {
    let chat: ChatListItem
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var isLoading = false
    
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
                                ForEach(authManager.conversationMessages) { message in
                                    MessageBubble(
                                        text: message.content,
                                        isFromUser: message.senderId == authManager.currentUser?.id.uuidString,
                                        time: formatMessageTime(message.createdAt),
                                        userInitial: message.senderId == authManager.currentUser?.id.uuidString ? 
                                            (authManager.profile?.username.prefix(1) ?? "U") : 
                                            chat.name.prefix(1),
                                        userColor: message.senderId == authManager.currentUser?.id.uuidString ? 
                                            .green : chat.profileColor
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    // Input bar (unchanged)
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "location")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        Button(action: {}) {
                            Image(systemName: "face.smiling")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        Button(action: {}) {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        TextField("Aa", text: $messageText)
                            .foregroundColor(.black)
                            .accentColor(.royalBlue)
                            .tint(.gray.opacity(0.9))
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(20)
                        Button(action: {
                            if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Task {
                                    isLoading = true
                                    let success = await authManager.sendMessage(
                                        content: messageText.trimmingCharacters(in: .whitespacesAndNewlines),
                                        to: chat.conversation.id
                                    )
                                    if success {
                                        messageText = ""
                                    }
                                    isLoading = false
                                }
                            }
                        }) {
                            Image(systemName: isLoading ? "clock" : "paperplane")
                                .font(.title3)
                                .foregroundColor(isLoading ? .gray : .royalBlue)
                        }
                        .disabled(isLoading || messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            .onAppear {
                Task {
                    await authManager.fetchMessages(for: chat.conversation.id)
                }
            }
        }
    }
}

// Helper function to format message time
func formatMessageTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter.string(from: date)
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

#Preview {
    ChatRoomView(
        chat: ChatListItem(
            conversation: Conversation(id: "preview", user1Id: "user1", user2Id: "user2", createdAt: Date(), updatedAt: Date()),
            otherUser: Profile(id: "user2", username: "Harrison Lin", avatarUrl: nil, bio: nil),
            lastMessage: Message(id: "msg1", conversationId: "preview", senderId: "user2", content: "See you in 30 min", messageType: .text, createdAt: Date(), updatedAt: Date())
        )
    )
    .environmentObject(AuthManager())
} 