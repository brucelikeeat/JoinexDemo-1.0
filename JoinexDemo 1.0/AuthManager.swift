import Foundation
import Supabase
import SwiftUI

// MARK: - Profile Model
struct Profile: Identifiable, Codable {
    let id: String
    var username: String
    var avatar_url: String?
    var bio: String?
    var created_at: String?
}

// MARK: - Event Model (temporary placement to resolve ambiguity)
struct Event: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String?
    let sportType: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let dateTime: Date
    let durationMinutes: Int
    let maxPlayers: Int
    let currentPlayers: Int
    let skillLevel: Int
    let hostId: String
    let status: EventStatus
    let createdAt: Date
    let updatedAt: Date
    
    // Custom initializer for creating events manually
    init(id: String, title: String, description: String?, sportType: String, location: String, latitude: Double?, longitude: Double?, dateTime: Date, durationMinutes: Int, maxPlayers: Int, currentPlayers: Int, skillLevel: Int, hostId: String, status: EventStatus, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.sportType = sportType
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.dateTime = dateTime
        self.durationMinutes = durationMinutes
        self.maxPlayers = maxPlayers
        self.currentPlayers = currentPlayers
        self.skillLevel = skillLevel
        self.hostId = hostId
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Computed properties
    var isFull: Bool {
        currentPlayers >= maxPlayers
    }
    
    var spotsRemaining: Int {
        maxPlayers - currentPlayers
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: dateTime)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dateTime)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: dateTime)
    }
    
    var skillLevelText: String {
        switch skillLevel {
        case 1...3: return "Beginner"
        case 4...6: return "Intermediate"
        case 7...8: return "Advanced"
        case 9...10: return "Expert"
        default: return "Intermediate"
        }
    }
    
    // MARK: - Event Status
    enum EventStatus: String, Codable, CaseIterable {
        case active = "active"
        case cancelled = "cancelled"
        case completed = "completed"
        
        var displayName: String {
            switch self {
            case .active: return "Active"
            case .cancelled: return "Cancelled"
            case .completed: return "Completed"
            }
        }
        
        var color: Color {
            switch self {
            case .active: return .green
            case .cancelled: return .red
            case .completed: return .gray
            }
        }
    }
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case sportType = "sport_type"
        case location
        case latitude
        case longitude
        case dateTime = "date_time"
        case durationMinutes = "duration_minutes"
        case maxPlayers = "max_players"
        case currentPlayers = "current_players"
        case skillLevel = "skill_level"
        case hostId = "host_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoding to handle date formats from Supabase
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        sportType = try container.decode(String.self, forKey: .sportType)
        location = try container.decode(String.self, forKey: .location)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        durationMinutes = try container.decode(Int.self, forKey: .durationMinutes)
        maxPlayers = try container.decode(Int.self, forKey: .maxPlayers)
        currentPlayers = try container.decode(Int.self, forKey: .currentPlayers)
        skillLevel = try container.decode(Int.self, forKey: .skillLevel)
        hostId = try container.decode(String.self, forKey: .hostId)
        status = try container.decode(EventStatus.self, forKey: .status)
        
        // Handle date decoding with multiple format support
        let dateTimeString = try container.decode(String.self, forKey: .dateTime)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        // Try different date formats
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
        
        let formatter2 = DateFormatter()
        formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        // Try to decode dates with different formatters
        var decodedDateTime: Date?
        var decodedCreatedAt: Date?
        var decodedUpdatedAt: Date?
        
        // Try ISO formatter first
        decodedDateTime = isoFormatter.date(from: dateTimeString)
        decodedCreatedAt = isoFormatter.date(from: createdAtString)
        decodedUpdatedAt = isoFormatter.date(from: updatedAtString)
        
        // Try other formatters if ISO didn't work
        if decodedDateTime == nil {
            decodedDateTime = formatter1.date(from: dateTimeString) ?? formatter2.date(from: dateTimeString)
        }
        if decodedCreatedAt == nil {
            decodedCreatedAt = formatter1.date(from: createdAtString) ?? formatter2.date(from: createdAtString)
        }
        if decodedUpdatedAt == nil {
            decodedUpdatedAt = formatter1.date(from: updatedAtString) ?? formatter2.date(from: updatedAtString)
        }
        
        guard let dateTime = decodedDateTime,
              let createdAt = decodedCreatedAt,
              let updatedAt = decodedUpdatedAt else {
            throw DecodingError.dataCorruptedError(forKey: .dateTime, in: container, debugDescription: "Unable to decode date format")
        }
        
        self.dateTime = dateTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Event Creation
struct CreateEventRequest: Codable {
    let title: String
    let description: String?
    let sportType: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let dateTime: Date
    let durationMinutes: Int
    let maxPlayers: Int
    let skillLevel: Int
    let hostId: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case sportType = "sport_type"
        case location
        case latitude
        case longitude
        case dateTime = "date_time"
        case durationMinutes = "duration_minutes"
        case maxPlayers = "max_players"
        case skillLevel = "skill_level"
        case hostId = "host_id"
    }
    
    // Custom encoding to format date properly for Supabase
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(sportType, forKey: .sportType)
        try container.encode(location, forKey: .location)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encode(durationMinutes, forKey: .durationMinutes)
        try container.encode(maxPlayers, forKey: .maxPlayers)
        try container.encode(skillLevel, forKey: .skillLevel)
        try container.encode(hostId, forKey: .hostId)
        
        // Format date as ISO 8601 string for Supabase
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateString = formatter.string(from: dateTime)
        try container.encode(dateString, forKey: .dateTime)
    }
}

// MARK: - Event Update
struct UpdateEventRequest: Codable {
    let title: String
    let description: String?
    let sportType: String
    let location: String
    let latitude: Double?
    let longitude: Double?
    let dateTime: Date
    let durationMinutes: Int
    let maxPlayers: Int
    let skillLevel: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case sportType = "sport_type"
        case location
        case latitude
        case longitude
        case dateTime = "date_time"
        case durationMinutes = "duration_minutes"
        case maxPlayers = "max_players"
        case skillLevel = "skill_level"
    }
}

@MainActor
class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profile: Profile?
    @Published var userEvents: [Event] = []
    @Published var hostedEvents: [Event] = []
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var conversationMessages: [Message] = []
    
    private let supabase = SupabaseConfig.client
    
    init() {
        // Check if user is already signed in
        Task {
            await checkCurrentUser()
        }
    }
    
    func checkCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            currentUser = session.user
            isAuthenticated = true
            // Fetch profile after successful authentication
            await fetchProfile()
        } catch {
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    func signUp(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            let user = response.user
            currentUser = user
            isAuthenticated = true
            // Create initial profile after signup
            await createInitialProfile(userId: user.id.uuidString)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            let user = response.user
            currentUser = user
            isAuthenticated = true
            // Fetch profile after successful signin
            await fetchProfile()
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await supabase.auth.signOut()
            currentUser = nil
            isAuthenticated = false
            profile = nil
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase.auth.resetPasswordForEmail(email)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Profile Management
    
    // Create initial profile after signup
    private func createInitialProfile(userId: String) async {
        do {
            let initialProfile: [String: String?] = [
                "id": userId,
                "username": "user_\(String(userId.prefix(8)))",
                "avatar_url": nil,
                "bio": nil
            ]
            
            _ = try await supabase
                .from("profiles")
                .insert(initialProfile)
                .execute()
            
            await fetchProfile()
        } catch {
            print("Error creating initial profile: \(error)")
        }
    }
    
    // Fetch user profile from Supabase
    func fetchProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let response: Profile = try await supabase
                .from("profiles")
                .select()
                
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.profile = response
        } catch {
            print("Error fetching profile: \(error)")
        }
    }
    
    // Update user profile in Supabase
    func updateProfile(username: String, avatar_url: String?, bio: String?) async -> Bool {
        guard let userId = currentUser?.id else { return false }
        
        do {
            // Create a clean dictionary with only non-nil values
            var updates: [String: String] = [
                "id": userId.uuidString,
                "username": username
            ]
            
            if let avatar_url = avatar_url {
                updates["avatar_url"] = avatar_url
            }
            
            if let bio = bio {
                updates["bio"] = bio
            }
            
            _ = try await supabase
                .from("profiles")
                .upsert(updates)
                .execute()
            
            await fetchProfile()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Event Management
    
    // Fetch all active events
    func fetchEvents() async {
        do {
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .order("date_time", ascending: true)
                .execute()
                .value
            
            self.userEvents = events
        } catch {
            print("Error fetching events: \(error)")
        }
    }
    
    // Fetch events hosted by current user
    func fetchHostedEvents() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("host_id", value: userId)
                .order("date_time", ascending: true)
                .execute()
                .value
            
            self.hostedEvents = events
        } catch {
            print("Error fetching hosted events: \(error)")
        }
    }
    
    // Create a new event
    func createEvent(_ eventRequest: CreateEventRequest) async -> Bool {
        print("AuthManager: Creating event with title: \(eventRequest.title)")
        
        // Debug: Print the encoded data
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(eventRequest)
            let jsonString = String(data: data, encoding: .utf8) ?? "Failed to encode"
            print("AuthManager: Sending data to Supabase: \(jsonString)")
        } catch {
            print("AuthManager: Failed to encode event request: \(error)")
        }
        
        do {
            let event: Event = try await supabase
                .from("events")
                .insert(eventRequest)
                .execute()
                .value
            
            print("AuthManager: Event created successfully")
            // Refresh hosted events
            await fetchHostedEvents()
            return true
        } catch {
            print("AuthManager: Error creating event: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Update an existing event
    func updateEvent(id: String, _ eventRequest: UpdateEventRequest) async -> Bool {
        do {
            let event: Event = try await supabase
                .from("events")
                .update(eventRequest)
                .eq("id", value: id)
                .execute()
                .value
            
            // Refresh hosted events
            await fetchHostedEvents()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Cancel an event
    func cancelEvent(id: String) async -> Bool {
        do {
            let event: Event = try await supabase
                .from("events")
                .update(["status": "cancelled"])
                .eq("id", value: id)
                .execute()
                .value
            
            // Refresh hosted events
            await fetchHostedEvents()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Join an event
    func joinEvent(id: String) async -> Bool {
        do {
            // First get the current event
            let event: Event = try await supabase
                .from("events")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            // Check if event is full
            guard event.currentPlayers < event.maxPlayers else {
                errorMessage = "Event is full"
                return false
            }
            
            // Update current players count
            let updatedEvent: Event = try await supabase
                .from("events")
                .update(["current_players": event.currentPlayers + 1])
                .eq("id", value: id)
                .execute()
                .value
            
            // Refresh events
            await fetchEvents()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Leave an event
    func leaveEvent(id: String) async -> Bool {
        do {
            // First get the current event
            let event: Event = try await supabase
                .from("events")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            // Check if we can leave
            guard event.currentPlayers > 1 else {
                errorMessage = "Cannot leave event with only 1 player"
                return false
            }
            
            // Update current players count
            let updatedEvent: Event = try await supabase
                .from("events")
                .update(["current_players": event.currentPlayers - 1])
                .eq("id", value: id)
                .execute()
                .value
            
            // Refresh events
            await fetchEvents()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Chat Management
    
    // Fetch all conversations for current user
    func fetchConversations() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            let conversations: [Conversation] = try await supabase
                .from("conversations")
                .select()
                .or("user1_id.eq.\(userId),user2_id.eq.\(userId)")
                .order("updated_at", ascending: false)
                .execute()
                .value
            
            self.conversations = conversations
        } catch {
            print("Error fetching conversations: \(error)")
        }
    }
    
    // Create or get existing conversation between two users
    func getOrCreateConversation(with userId: String) async -> Conversation? {
        guard let currentUserId = currentUser?.id else { return nil }
        
        do {
            // Try to find existing conversation
            let existingConversations: [Conversation] = try await supabase
                .from("conversations")
                .select()
                .or("and(user1_id.eq.\(currentUserId),user2_id.eq.\(userId)),and(user1_id.eq.\(userId),user2_id.eq.\(currentUserId))")
                .execute()
                .value
            
            if let existing = existingConversations.first {
                return existing
            }
            
            // Create new conversation
            let newConversation: Conversation = try await supabase
                .from("conversations")
                .insert([
                    "user1_id": currentUserId,
                    "user2_id": userId
                ])
                .execute()
                .value
            
            return newConversation
        } catch {
            print("Error creating conversation: \(error)")
            return nil
        }
    }
    
    // Fetch messages for a conversation
    func fetchMessages(for conversationId: String) async {
        do {
            let messages: [Message] = try await supabase
                .from("messages")
                .select()
                .eq("conversation_id", value: conversationId)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            self.conversationMessages = messages
        } catch {
            print("Error fetching messages: \(error)")
        }
    }
    
    // Send a message
    func sendMessage(content: String, to conversationId: String) async -> Bool {
        guard let senderId = currentUser?.id else { return false }
        
        do {
            let message: Message = try await supabase
                .from("messages")
                .insert([
                    "conversation_id": conversationId,
                    "sender_id": senderId,
                    "content": content,
                    "message_type": "text"
                ])
                .execute()
                .value
            
            // Refresh messages
            await fetchMessages(for: conversationId)
            
            // Update conversation's updated_at timestamp
            _ = try await supabase
                .from("conversations")
                .update(["updated_at": "now()"])
                .eq("id", value: conversationId)
                .execute()
            
            // Refresh conversations list
            await fetchConversations()
            
            return true
        } catch {
            print("Error sending message: \(error)")
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Get chat list items with user profiles
    func getChatListItems() async -> [ChatListItem] {
        var chatItems: [ChatListItem] = []
        
        for conversation in conversations {
            // Get the other user's ID
            let otherUserId = conversation.user1Id == currentUser?.id.uuidString ? conversation.user2Id : conversation.user1Id
            
            // Fetch the other user's profile
            do {
                let otherUser: Profile = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: otherUserId)
                    .single()
                    .execute()
                    .value
                
                // Get the last message
                let lastMessages: [Message] = try await supabase
                    .from("messages")
                    .select()
                    .eq("conversation_id", value: conversation.id)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                    .value
                
                let lastMessage = lastMessages.first
                
                let chatItem = ChatListItem(
                    conversation: conversation,
                    otherUser: otherUser,
                    lastMessage: lastMessage
                )
                chatItems.append(chatItem)
            } catch {
                print("Error fetching chat item data: \(error)")
            }
        }
        
        return chatItems
    }
}
 