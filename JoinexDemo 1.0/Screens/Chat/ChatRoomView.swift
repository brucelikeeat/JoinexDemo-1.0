//
//  ChatRoomView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ChatRoomView: View {
    let chat: Chat
    let chatHistory: [Message]
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
                                .fill(chat.profileColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    chat.profileImage.isEmpty ?
                                        AnyView(Text(chat.name.prefix(1))
                                            .font(.system(size: 16, weight: .bold, design: .default))
                                            .foregroundColor(.white))
                                        :
                                        AnyView(Image(systemName: chat.profileImage)
                                            .foregroundColor(.white)
                                            .font(.title3))
                                )
                            VStack(alignment: .leading, spacing: 2) {
                                Text(chat.name)
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                Text(chat.isActive ? "Active now" : "Offline")
                                    .font(.system(size: 12, weight: .regular, design: .default))
                                    .foregroundColor(chat.isActive ? .green : .gray)
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
                            ForEach(chatHistory) { msg in
                                MessageBubble(
                                    text: msg.text,
                                    isFromUser: msg.isFromUser,
                                    time: msg.time,
                                    userInitial: msg.isFromUser ? "BL" : String(chat.name.prefix(1)),
                                    userColor: msg.isFromUser ? Color.green : chat.profileColor
                                )
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
                        Button(action: { messageText = "" }) {
                            Image(systemName: "paperplane")
                                .font(.title3)
                                .foregroundColor(.royalBlue)
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
        chat: Chat(name: "Harrison Lin", lastMessage: "See you in 30 min", lastMessageTime: "12:03", profileColor: .blue, profileImage: "person.fill", isActive: true),
        chatHistory: [
            Message(text: "See you in 30 min", isFromUser: false, time: "11:59", userInitial: nil, userColor: nil),
            Message(text: "Prepared some donuts for you. Bet you'll love them 😋😋", isFromUser: true, time: "12:01", userInitial: "BL", userColor: .green),
            Message(text: "Thats a lot 🎉🎉🎉", isFromUser: false, time: "12:03", userInitial: nil, userColor: nil)
        ]
    )
} 