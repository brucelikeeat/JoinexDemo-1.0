import Foundation
import SwiftUI

// MARK: - Chat Data Models

struct Conversation: Identifiable, Codable, Hashable {
    let id: String
    let user1Id: String
    let user2Id: String
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case user1Id = "user1_id"
        case user2Id = "user2_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ConversationWithDetails: Codable {
    let id: String
    let user1_id: String
    let user2_id: String
    let created_at: Date
    let updated_at: Date
    let other_user_id: String
    let other_user_name: String?
    let last_message_content: String?
    let last_message_time: Date?
}

struct MessageWithDetails: Codable {
    let id: String
    let conversation_id: String
    let sender_id: String
    let content: String
    let message_type: String
    let created_at: Date
    let sender_name: String?
}

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let messageType: MessageType
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case content
        case messageType = "message_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case location = "location"
}

struct ChatListItem: Identifiable, Hashable, Equatable {
    let id: String
    let conversation: Conversation
    let otherUser: Profile
    let lastMessage: ChatMessage?
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(conversation.id)
        hasher.combine(otherUser.id)
    }
    
    // Custom Equatable implementation
    static func == (lhs: ChatListItem, rhs: ChatListItem) -> Bool {
        return lhs.id == rhs.id && 
               lhs.conversation.id == rhs.conversation.id &&
               lhs.otherUser.id == rhs.otherUser.id
    }
    
    var name: String {
        otherUser.username
    }
    
    var lastMessageText: String {
        lastMessage?.content ?? "No messages yet"
    }
    
    var lastMessageTime: String {
        guard let lastMessage = lastMessage else { return "" }
        return formatMessageTime(lastMessage.createdAt)
    }
    
    var profileColor: Color {
        // Generate consistent color based on user ID
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
        let index = abs(otherUser.id.hashValue) % colors.count
        return colors[index]
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat UI Models (for backward compatibility)

struct Chat: Identifiable, Hashable {
    let id: String
    let name: String
    let lastMessage: String
    let lastMessageTime: String
    let profileColor: Color
}

struct ChatMessageUI: Identifiable, Hashable {
    let id: String
    let text: String
    let isFromUser: Bool
    let time: String
}

// MARK: - Chat Error Types

enum ChatError: Error, LocalizedError {
    case conversationNotFound
    case messageSendFailed
    case userNotFound
    case invalidConversation
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .conversationNotFound:
            return "Conversation not found"
        case .messageSendFailed:
            return "Failed to send message"
        case .userNotFound:
            return "User not found"
        case .invalidConversation:
            return "Invalid conversation"
        case .networkError:
            return "Network error occurred"
        }
    }
} 