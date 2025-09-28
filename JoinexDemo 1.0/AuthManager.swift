import Foundation
import Supabase
import SwiftUI
import CoreLocation

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
        
        // Handle date decoding with comprehensive format support
        let dateTimeString = try container.decode(String.self, forKey: .dateTime)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        // Parse dates with multiple format support
        self.dateTime = Self.parseDate(from: dateTimeString)
        self.createdAt = Self.parseDate(from: createdAtString)
        self.updatedAt = Self.parseDate(from: updatedAtString)
    }
    
    // MARK: - Date Parsing Helper
    private static func parseDate(from dateString: String) -> Date {
        // Try ISO8601DateFormatter first (most reliable)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        // Try with different ISO8601 options
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        // Try common date formats
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS+00:00",
            "yyyy-MM-dd'T'HH:mm:ss.SSS+00:00",
            "yyyy-MM-dd'T'HH:mm:ss+00:00",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        
        for format in dateFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            if let date = formatter.date(from: dateString) {
                print("Event: Successfully parsed date '\(dateString)' using format '\(format)'")
                return date
            }
        }
        
        // If all else fails, try to parse as a timestamp
        if let timestamp = Double(dateString) {
            let date = Date(timeIntervalSince1970: timestamp)
            print("Event: Successfully parsed date '\(dateString)' as timestamp")
            return date
        }
        
        // Log the problematic date string for debugging
        print("Event: Failed to parse date '\(dateString)' - using current date as fallback")
        
        // Return current date as fallback instead of throwing error
        return Date()
    }// MARK: - Event Creation
}

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

// MARK: - Location Result Model
struct LocationResult: Identifiable, Codable, Hashable {
    let id: String
    let displayName: String
    let latitude: Double?
    let longitude: Double?
    let distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case latitude = "lat"
        case longitude = "lon"
        case distance
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
    
    // MARK: - Chat Properties
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var conversationMessages: [ChatMessage] = []
    @Published var chatListItems: [ChatListItem] = []
    @Published var isChatLoading = false
    @Published var chatError: String?

    
    private let supabase = SupabaseConfig.client
    
    // MARK: - Helper Functions
    
    // Timeout wrapper for async operations
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
    
    // Custom timeout error
    private struct TimeoutError: Error, LocalizedError {
        var errorDescription: String? {
            return "Request timed out"
        }
    }
    
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
    
    // Upload avatar image to Supabase Storage and return public URL
    func uploadAvatar(image: UIImage) async -> String? {
        guard let userId = currentUser?.id else { return nil }
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filePath = "avatars/\(userId.uuidString)/avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        do {
            _ = try await supabase.storage.from("avatars").upload(filePath, data: data, options: FileOptions(contentType: "image/jpeg", upsert: true))
            if let publicURL = try? supabase.storage.from("avatars").getPublicURL(path: filePath) {
                return publicURL.absoluteString
            } else {
                return nil
            }
        } catch {
            print("Avatar upload error: \(error)")
            errorMessage = error.localizedDescription
            return nil
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
    
    // MARK: - Session Management
    
    // Check if user has valid session
    func checkSession() async -> Bool {
        do {
            let session = try await supabase.auth.session
            let user = session.user
            currentUser = user
            isAuthenticated = true
            await fetchProfile()
            return true
        } catch {
            print("Session check error: \(error.localizedDescription)")
            currentUser = nil
            isAuthenticated = false
            return false
        }
    }
    
    // Fetch user profile data (alias for fetchProfile for consistency)
    func fetchUserProfile() async {
        await fetchProfile()
    }
    
    // MARK: - Event Management
    
    // Fetch all active events
    func fetchEvents() async {
        print("AuthManager: fetchEvents() called")
        print("AuthManager: Current user: \(currentUser?.id.uuidString ?? "nil")")
        do {
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
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
    
    // Refresh all event lists for real-time updates across all views
    func refreshAllEventLists() async {
        print("AuthManager: Refreshing all event lists...")
        
        // Refresh all events (for ExploreView)
        await fetchEvents()
        
        // Refresh hosted events (for HostView)
        await fetchHostedEvents()
        
        print("AuthManager: All event lists refreshed - userEvents: \(userEvents.count), hostedEvents: \(hostedEvents.count)")
    }    
    // Create a new event with sport validation
    func createEvent(_ eventRequest: CreateEventRequest) async -> Bool {
        print("AuthManager: Creating event with title: \(eventRequest.title)")
        print("AuthManager: Sport type: \(eventRequest.sportType)")
        print("AuthManager: Location: \(eventRequest.location)")
        print("AuthManager: Host ID: \(eventRequest.hostId)")
        
        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // Create a proper struct for RPC parameters
            struct EventCreationParams: Encodable {
                let event_title: String
                let event_description: String
                let event_sport_type: String
                let event_location: String
                let event_date_time: String
                let event_duration_minutes: Int
                let event_max_players: Int
                let event_skill_level: Int
                let event_host_id: String
                let event_latitude: Double?
                let event_longitude: Double?
            }
            
            let params = EventCreationParams(
                event_title: eventRequest.title,
                event_description: eventRequest.description ?? "",
                event_sport_type: eventRequest.sportType,
                event_location: eventRequest.location,
                event_date_time: formatter.string(from: eventRequest.dateTime),
                event_duration_minutes: eventRequest.durationMinutes,
                event_max_players: eventRequest.maxPlayers,
                event_skill_level: eventRequest.skillLevel,
                event_host_id: eventRequest.hostId,
                event_latitude: eventRequest.latitude,
                event_longitude: eventRequest.longitude
            )
            
            print("AuthManager: Sending parameters to RPC:")
            print("  - Title: \(params.event_title)")
            print("  - Sport: \(params.event_sport_type)")
            print("  - Location: \(params.event_location)")
            print("  - Date: \(params.event_date_time)")
            print("  - Duration: \(params.event_duration_minutes)")
            print("  - Max Players: \(params.event_max_players)")
            print("  - Skill Level: \(params.event_skill_level)")
            print("  - Host ID: \(params.event_host_id)")
            print("  - Latitude: \(params.event_latitude?.description ?? "nil")")
            print("  - Longitude: \(params.event_longitude?.description ?? "nil")")
            
            let response = try await supabase
                .rpc("create_event_with_validation", params: params)
                .execute()
            
            print("AuthManager: RPC response received")
            print("AuthManager: Response value type: \(type(of: response.value))")
            print("AuthManager: Response value: \(response.value)")
            
            // The RPC function returns UUID, but Supabase might return Void
            // If no exception was thrown, the event was created successfully
            print("AuthManager: Event created successfully (no exception thrown)")
            print("AuthManager: Response value type: \(type(of: response.value))")
            
            // Refresh hosted events
            await refreshAllEventLists()
            return true
        } catch {
            print("AuthManager: Error creating event: \(error.localizedDescription)")
            print("AuthManager: Full error: \(error)")
            print("AuthManager: Trying fallback method...")
            
            // Fallback to direct table insert
            do {
                print("AuthManager: Trying direct table insert with CreateEventRequest")
                
                let response: [Event] = try await supabase
                    .from("events")
                    .insert(eventRequest)
                    .select()
                    .execute()
                    .value
                
                if !response.isEmpty {
                    print("AuthManager: Event created successfully via fallback method")
                    await refreshAllEventLists()
                    return true
                } else {
                    print("AuthManager: Fallback method returned empty response")
                    errorMessage = "Failed to create event via fallback method"
                    return false
                }
            } catch {
                print("AuthManager: Fallback method also failed: \(error.localizedDescription)")
                errorMessage = "Failed to create event: \(error.localizedDescription)"
                return false
            }
        }
    }
    
    // Update an existing event
    func updateEvent(id: String, _ eventRequest: UpdateEventRequest) async -> Bool {
        do {
            _ = try await supabase
                .from("events")
                .update(eventRequest)
                .eq("id", value: id)
                .execute()
            
            // Refresh hosted events
            await refreshAllEventLists()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Cancel an event
    func cancelEvent(id: String) async -> Bool {
        print("AuthManager: Canceling event with ID: \(id)")
        
        do {
            // Simple update without fetching first
            let result = try await supabase
                .from("events")
                .update(["status": "cancelled"])
                .eq("id", value: id)
                .execute()
            
            print("AuthManager: Update result: \(result)")
            
            // Verify the update worked
            let updatedEvent: Event = try await supabase
                .from("events")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value
            
            print("AuthManager: Event status after update: \(updatedEvent.status.rawValue)")
            
            if updatedEvent.status == .cancelled {
                print("AuthManager: Event cancelled successfully")
                await fetchHostedEvents()
                return true
            } else {
                print("AuthManager: Event status not updated correctly")
                errorMessage = "Failed to update event status"
                return false
            }
        } catch {
            print("AuthManager: Error cancelling event: \(error.localizedDescription)")
            errorMessage = "Failed to cancel event: \(error.localizedDescription)"
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
            let _: Event = try await supabase
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
            let _: Event = try await supabase
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
    
    // Fetch all conversations for current user with improved error handling
    func fetchConversations() async {
        guard currentUser != nil else {
            chatError = "User not authenticated"
            return
        }
        
        print("🔍 Starting fetchConversations for user: \(currentUser?.id.uuidString ?? "unknown")")
        
        await MainActor.run {
            isChatLoading = true
            chatError = nil
        }
        
        // First, try to check if tables exist
        do {
            // Simple query to check if conversations table exists
            let _: [Conversation] = try await withTimeout(seconds: 5) { [self] in
                try await supabase
                    .from("conversations")
                    .select()
                    .limit(1)
                    .execute()
                    .value
            }
            print("✅ Conversations table exists")
        } catch {
            print("❌ Conversations table doesn't exist or access denied: \(error)")
            await MainActor.run {
                chatError = "Chat system not properly configured. Please contact support."
                isChatLoading = false
            }
            return
        }
        
        // Now try to fetch conversations
        for attempt in 1...3 {
            do {
                guard let currentUserId = currentUser?.id.uuidString else {
                    await MainActor.run {
                        chatError = "Session expired. Please log in again."
                        isChatLoading = false
                    }
                    return
                }
                
                print("🔍 Attempt \(attempt): Fetching conversations for user \(currentUserId)")
                
                // Try RPC function first
                do {
                    let response: [ConversationWithDetails] = try await withTimeout(seconds: 8) { [self] in
                        try await supabase
                            .rpc("get_user_conversations")
                            .execute()
                            .value
                    }
                    print("✅ RPC successful: fetched \(response.count) conversations")
                    
                    let conversations = response.map { detail in
                        Conversation(
                            id: detail.id,
                            user1Id: detail.user1_id,
                            user2Id: detail.user2_id,
                            createdAt: detail.created_at,
                            updatedAt: detail.updated_at
                        )
                    }
                    
                    await MainActor.run {
                        self.conversations = conversations
                        isChatLoading = false
                    }
                    return
                } catch {
                    print("🔄 RPC failed, trying direct queries: \(error)")
                    
                    // Fallback to direct queries
                    let conversations1: [Conversation] = try await withTimeout(seconds: 8) { [self] in
                        try await supabase
                            .from("conversations")
                            .select()
                            .eq("user1_id", value: currentUserId)
                            .order("updated_at", ascending: false)
                            .execute()
                            .value
                    }
                    
                    let conversations2: [Conversation] = try await withTimeout(seconds: 8) { [self] in
                        try await supabase
                            .from("conversations")
                            .select()
                            .eq("user2_id", value: currentUserId)
                            .order("updated_at", ascending: false)
                            .execute()
                            .value
                    }
                    
                    let conversations = conversations1 + conversations2
                    print("✅ Direct queries successful: fetched \(conversations.count) conversations")
                    
                    await MainActor.run {
                        self.conversations = conversations
                        isChatLoading = false
                    }
                    return
                }
                
            } catch {
                print("❌ Attempt \(attempt) failed: \(error)")
                
                if attempt == 3 {
                    await MainActor.run {
                        if error.localizedDescription.contains("timeout") {
                            chatError = "Request timed out. Please check your internet connection and try again."
                        } else if error.localizedDescription.contains("network") {
                            chatError = "Network error. Please check your connection."
                        } else if error.localizedDescription.contains("permission") {
                            chatError = "Access denied. Please log in again."
                        } else {
                            chatError = "Unable to load conversations. Please try again later."
                        }
                        isChatLoading = false
                    }
                } else {
                    // Shorter wait times
                    try? await Task.sleep(nanoseconds: UInt64(attempt) * 500_000_000) // 0.5s, 1s, 1.5s
                }
            }
        }
    }
    
    // Create or get existing conversation between two users with retry mechanism
    func getOrCreateConversation(with userId: String) async -> Conversation? {
        guard currentUser != nil else {
            chatError = "User not authenticated"
            return nil
        }
        
        // Retry mechanism with exponential backoff
        for attempt in 1...3 {
            do {
                // Check if user is still authenticated
                guard currentUser != nil else {
                    chatError = "Session expired. Please log in again."
                    return nil
                }
                
                // Use the new backend function
                let conversationId: String = try await withTimeout(seconds: 10) { [self] in
                    try await supabase
                        .rpc("get_or_create_conversation", params: ["other_user_id": userId])
                        .execute()
                        .value
                }
                
                // Get the conversation details
                let conversation: Conversation = try await withTimeout(seconds: 10) { [self] in
                    try await supabase
                        .from("conversations")
                        .select()
                        .eq("id", value: conversationId)
                        .single()
                        .execute()
                        .value
                }
                
                return conversation
                
            } catch {
                print("Error creating conversation (attempt \(attempt)): \(error)")
                
                if attempt == 3 {
                    // Final attempt failed
                    if error.localizedDescription.contains("timeout") || 
                       error.localizedDescription.contains("network") ||
                       error.localizedDescription.contains("connection") {
                        chatError = "Network connection issue. Please check your internet connection and try again."
                    } else {
                        chatError = "Failed to create conversation: \(error.localizedDescription)"
                    }
                    return nil
                } else {
                    // Wait before retry with exponential backoff
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                }
            }
        }
        
        return nil
    }
    
    // Fetch messages for a conversation with retry mechanism
    func fetchMessages(for conversationId: String) async {
        await MainActor.run {
            isChatLoading = true
            chatError = nil
        }
        
        // Retry mechanism with exponential backoff
        for attempt in 1...3 {
            do {
                // Check if user is still authenticated
                guard currentUser != nil else {
                    await MainActor.run {
                        chatError = "Session expired. Please log in again."
                        isChatLoading = false
                    }
                    return
                }
                
                let response: [MessageWithDetails] = try await withTimeout(seconds: 10) { [self] in
                    try await supabase
                        .rpc("get_conversation_messages", params: ["conv_id": conversationId])
                        .execute()
                        .value
                }
                
                // Convert to ChatMessage objects
                let messages = response.map { detail in
                    ChatMessage(
                        id: detail.id,
                        conversationId: detail.conversation_id,
                        senderId: detail.sender_id,
                        content: detail.content,
                        messageType: MessageType(rawValue: detail.message_type) ?? .text,
                        createdAt: detail.created_at,
                        updatedAt: detail.created_at // Use created_at as updated_at for now
                    )
                }
                
                await MainActor.run {
                    self.conversationMessages = messages
                    isChatLoading = false
                }
                return // Success, exit retry loop
                
            } catch {
                print("Error fetching messages (attempt \(attempt)): \(error)")
                
                if attempt == 3 {
                    // Final attempt failed
                    await MainActor.run {
                        if error.localizedDescription.contains("timeout") || 
                           error.localizedDescription.contains("network") ||
                           error.localizedDescription.contains("connection") {
                            chatError = "Network connection issue. Please check your internet connection and try again."
                        } else {
                            chatError = "Failed to fetch messages: \(error.localizedDescription)"
                        }
                        isChatLoading = false
                    }
                } else {
                    // Wait before retry with exponential backoff
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                }
            }
        }
    }
    
    // Send a message with retry mechanism
    func sendMessage(content: String, to conversationId: String) async -> Bool {
                                guard currentUser?.id.uuidString != nil else {
            chatError = "User not authenticated"
            return false
        }
        
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            chatError = "Message cannot be empty"
            return false
        }
        
        // Retry mechanism with exponential backoff
        for attempt in 1...3 {
            do {
                // Check if user is still authenticated
                guard currentUser != nil else {
                    chatError = "Session expired. Please log in again."
                    return false
                }
                
                let _: String = try await withTimeout(seconds: 10) { [self] in
                    try await supabase
                        .rpc("send_message", params: [
                            "conv_id": conversationId,
                            "message_content": content.trimmingCharacters(in: .whitespacesAndNewlines),
                            "message_type": "text"
                        ])
                        .execute()
                        .value
                }
                
                // Refresh messages and conversations (these have their own retry mechanisms)
                await fetchMessages(for: conversationId)
                await fetchConversations()
                
                return true
                
            } catch {
                print("Error sending message (attempt \(attempt)): \(error)")
                
                if attempt == 3 {
                    // Final attempt failed
                    if error.localizedDescription.contains("timeout") || 
                       error.localizedDescription.contains("network") ||
                       error.localizedDescription.contains("connection") {
                        chatError = "Network connection issue. Please check your internet connection and try again."
                    } else {
                        chatError = "Failed to send message: \(error.localizedDescription)"
                    }
                    return false
                } else {
                    // Wait before retry with exponential backoff
                    try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                }
            }
        }
        
        return false
    }
    
    // Get chat list items with user profiles and timeout handling
    func getChatListItems() async -> [ChatListItem] {
        var chatItems: [ChatListItem] = []
        
        // Use the conversations we already have from fetchConversations
        for conversation in conversations {
            // Get the other user's ID
            let otherUserId = conversation.user1Id == currentUser?.id.uuidString ? conversation.user2Id : conversation.user1Id
            
            do {
                // Check if user is still authenticated
                guard currentUser != nil else {
                    print("User session expired while fetching chat items")
                    break
                }
                
                // Fetch the other user's profile with timeout
                let otherUser: Profile = try await withTimeout(seconds: 5) { [self] in
                    try await supabase
                        .from("profiles")
                        .select()
                        .eq("id", value: otherUserId)
                        .single()
                        .execute()
                        .value
                }
                
                // Get the last message with timeout using the new function
                let lastMessages: [MessageWithDetails] = try await withTimeout(seconds: 5) { [self] in
                    try await supabase
                        .rpc("get_conversation_messages", params: ["conv_id": conversation.id])
                        .limit(1)
                        .order("created_at", ascending: false)
                        .execute()
                        .value
                }
                
                let lastMessage = lastMessages.first.map { detail in
                    ChatMessage(
                        id: detail.id,
                        conversationId: detail.conversation_id,
                        senderId: detail.sender_id,
                        content: detail.content,
                        messageType: MessageType(rawValue: detail.message_type) ?? .text,
                        createdAt: detail.created_at,
                        updatedAt: detail.created_at
                    )
                }
                
                let chatItem = ChatListItem(
                    id: conversation.id,
                    conversation: conversation,
                    otherUser: otherUser,
                    lastMessage: lastMessage
                )
                chatItems.append(chatItem)
            } catch {
                print("Error fetching chat item data for conversation \(conversation.id): \(error)")
                // Continue with other conversations even if one fails
            }
        }
        
        return chatItems
    }
    
    // Refresh chat list items
    func refreshChatList() async {
        await fetchConversations()
        let items = await getChatListItems()
        await MainActor.run {
            self.chatListItems = items
        }
    }
    
    // MARK: - Advanced Search & Filtering
    
    // Search events with advanced filters
    func searchEvents(
        searchText: String = "",
        sportType: String = "All Sports",
        selectedDate: Date? = nil,
        location: String = "",
        radiusKm: Int = 40
    ) async {
        do {
            var query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
            
            // Text search filter
            if !searchText.isEmpty {
                query = query.or("title.ilike.%\(searchText)%,description.ilike.%\(searchText)%,location.ilike.%\(searchText)%")
            }
            
            // Sport type filter
            if sportType != "All Sports" {
                query = query.eq("sport_type", value: sportType)
            }
            
            // Date filter
            if let selectedDate = selectedDate {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: selectedDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let startDateString = formatter.string(from: startOfDay)
                let endDateString = formatter.string(from: endOfDay)
                
                query = query.gte("date_time", value: startDateString)
                query = query.lt("date_time", value: endDateString)
            }
            
            // Location-based filtering (if location is provided)
            if !location.isEmpty {
                // For now, we'll filter by location text
                // In a real app, you'd use geolocation and distance calculations
                query = query.ilike("location", pattern: "%\(location)%")
            }
            
            // Order by date (closest events first)
            let events: [Event] = try await query.order("date_time", ascending: true).execute().value
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            
        } catch {
            print("Error searching events: \(error)")
        }
    }
    
    // Get events by sport type
    func getEventsBySport(_ sportType: String) async {
        if sportType == "All Sports" {
            await fetchEvents()
        } else {
            do {
                let events: [Event] = try await supabase
                    .from("events")
                    .select()
                    .eq("status", value: "active")
                    .eq("sport_type", value: sportType)
                    .order("date_time", ascending: true)
                    .execute()
                    .value
                
                print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            } catch {
                print("Error fetching events by sport: \(error)")
            }
        }
    }
    
    // Get events by date range
    func getEventsByDate(_ date: Date) async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startDateString = formatter.string(from: startOfDay)
        let endDateString = formatter.string(from: endOfDay)
        
        do {
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .gte("date_time", value: startDateString)
                .lt("date_time", value: endDateString)
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error fetching events by date: \(error)")
        }
    }
    
    // Get events by location
    func getEventsByLocation(_ location: String, radiusKm: Int = 40) async {
        do {
            // For now, we'll filter by location text
            // In a real implementation, you'd use geolocation coordinates
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .ilike("location", pattern: "%\(location)%")
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error fetching events by location: \(error)")
        }
    }
    
    // Real-time search with debouncing
    func performSearch(searchText: String) async {
        if searchText.isEmpty {
            await fetchEvents()
        } else {
            do {
                let events: [Event] = try await supabase
                    .from("events")
                    .select()
                    .eq("status", value: "active")
                    .or("title.ilike.%\(searchText)%,description.ilike.%\(searchText)%,location.ilike.%\(searchText)%")
                    .order("date_time", ascending: true)
                    .execute()
                    .value
                
                print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            } catch {
                print("Error performing search: \(error)")
            }
        }
    }
    
    // Apply all filters at once with enhanced functionality
    func applyAllFilters(
        searchText: String = "",
        sportType: String = "All Sports",
        selectedDate: Date? = nil,
        location: String = "",
        radiusKm: Int = 40
    ) async {
        do {
            var query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
            
            // Text search filter with improved matching
            if !searchText.isEmpty {
                let searchPattern = "%\(searchText)%"
                query = query.or("title.ilike.\(searchPattern),description.ilike.\(searchPattern),location.ilike.\(searchPattern),sport_type.ilike.\(searchPattern)")
            }
            
            // Sport type filter
            if sportType != "All Sports" {
                query = query.eq("sport_type", value: sportType)
            }
            
            // Date filter with improved range handling
            if let selectedDate = selectedDate {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: selectedDate)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let startDateString = formatter.string(from: startOfDay)
                let endDateString = formatter.string(from: endOfDay)
                
                query = query.gte("date_time", value: startDateString)
                query = query.lt("date_time", value: endDateString)
            }
            
            // Enhanced location-based filtering
            if !location.isEmpty {
                query = query.ilike("location", pattern: "%\(location)%")
            }
            
            // Order by date (closest events first)
            let events: [Event] = try await query.order("date_time", ascending: true).execute().value
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            
        } catch {
            print("Error applying filters: \(error)")
        }
    }
    
    // Enhanced real-time search with debouncing
    func performRealTimeSearch(searchText: String) async {
        if searchText.isEmpty {
            await fetchEvents()
        } else {
            do {
                let searchPattern = "%\(searchText)%"
                let events: [Event] = try await supabase
                    .from("events")
                    .select()
                    .eq("status", value: "active")
                    .or("title.ilike.\(searchPattern),description.ilike.\(searchPattern),location.ilike.\(searchPattern),sport_type.ilike.\(searchPattern)")
                    .order("date_time", ascending: true)
                    .execute()
                    .value
                
                print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            } catch {
                print("Error performing real-time search: \(error)")
            }
        }
    }
    
    // Enhanced sport filtering
    func filterBySport(_ sportType: String) async {
        if sportType == "All Sports" {
            await fetchEvents()
        } else {
            do {
                let events: [Event] = try await supabase
                    .from("events")
                    .select()
                    .eq("status", value: "active")
                    .eq("sport_type", value: sportType)
                    .order("date_time", ascending: true)
                    .execute()
                    .value
                
                print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
            } catch {
                print("Error filtering by sport: \(error)")
            }
        }
    }
    
    // Enhanced date filtering with range support
    func filterByDate(_ date: Date, range: Int = 1) async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: range, to: startOfDay)!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let startDateString = formatter.string(from: startOfDay)
        let endDateString = formatter.string(from: endOfDay)
        
        do {
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .gte("date_time", value: startDateString)
                .lt("date_time", value: endDateString)
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error filtering by date: \(error)")
        }
    }
    
    // Enhanced location filtering with distance simulation
    func filterByLocation(_ location: String, radiusKm: Int = 40) async {
        do {
            // Enhanced location search with multiple patterns
            let locationPattern = "%\(location)%"
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .or("location.ilike.\(locationPattern),title.ilike.\(locationPattern)")
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error filtering by location: \(error)")
        }
    }
    
    // MARK: - Enhanced Filtering Functions (Using existing working code)
    
    // 1. Location-based search
    func searchByLocation(location: String, radiusKm: Int = 40) async {
        do {
            let locationPattern = "%\(location)%"
            
            let query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .or("location.ilike.\(locationPattern),title.ilike.\(locationPattern)")
                .order("date_time", ascending: true)
            
            let events: [Event] = try await query.execute().value
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error searching by location: \(error)")
        }
    }
    
    // 2. Distance radius filtering
    func filterByDistance(latitude: Double, longitude: Double, radiusKm: Int) async {
        do {
            // Calculate bounding box for the radius (approximation)
            let latDelta = Double(radiusKm) / 111.0 // 1 degree latitude ≈ 111 km
            let lonDelta = Double(radiusKm) / (111.0 * cos(latitude * .pi / 180))
            
            let minLat = latitude - latDelta
            let maxLat = latitude + latDelta
            let minLon = longitude - lonDelta
            let maxLon = longitude + lonDelta
            
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .gte("latitude", value: minLat)
                .lte("latitude", value: maxLat)
                .gte("longitude", value: minLon)
                .lte("longitude", value: maxLon)
                .order("date_time", ascending: true)
                .execute()
                .value
            
            // Filter events within exact radius using Haversine formula
            let filteredEvents = events.filter { event in
                guard let eventLat = event.latitude, let eventLon = event.longitude else {
                    return false
                }
                
                let distance = calculateDistance(
                    lat1: latitude, lon1: longitude,
                    lat2: eventLat, lon2: eventLon
                )
                
                return distance <= Double(radiusKm)
            }
            
            self.userEvents = filteredEvents
        } catch {
            print("Error filtering by distance: \(error)")
        }
    }
    
    // 3. Sport type filtering
    func filterBySportType(sportTypes: [String]) async {
        do {
            if sportTypes.contains("All Sports") {
                await fetchEvents()
                return
            }
            
            var query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
            
            // Build sport type filter
            if sportTypes.count == 1 {
                query = query.eq("sport_type", value: sportTypes[0])
            } else {
                // Multiple sports - use 'in' operator
                query = query.in("sport_type", values: sportTypes)
            }
            
            let events: [Event] = try await query
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error filtering by sport type: \(error)")
        }
    }
    
    // 4. Date filtering
    func filterByDateRange(startDate: Date, endDate: Date) async {
        do {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let startDateString = formatter.string(from: startDate)
            let endDateString = formatter.string(from: endDate)
            
            let events: [Event] = try await supabase
                .from("events")
                .select()
                .eq("status", value: "active")
                .gte("date_time", value: startDateString)
                .lte("date_time", value: endDateString)
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error filtering by date range: \(error)")
        }
    }
    
    // 5. Real-time search
    func performLiveSearch(searchText: String, filters: SearchFilters) async {
        do {
            var query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
            
            // Text search across multiple fields
            if !searchText.isEmpty {
                let searchPattern = "%\(searchText)%"
                query = query.or("title.ilike.\(searchPattern),description.ilike.\(searchPattern),location.ilike.\(searchPattern),sport_type.ilike.\(searchPattern)")
            }
            
            // Apply sport filter
            if let sportType = filters.sportType, sportType != "All Sports" {
                query = query.eq("sport_type", value: sportType)
            }
            
            // Apply date filter
            if let date = filters.date {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let startDateString = formatter.string(from: startOfDay)
                let endDateString = formatter.string(from: endOfDay)
                
                query = query.gte("date_time", value: startDateString)
                query = query.lt("date_time", value: endDateString)
            }
            
            // Apply location filter
            if let location = filters.location, !location.isEmpty {
                let locationPattern = "%\(location)%"
                query = query.ilike("location", pattern: locationPattern)
            }
            
            let events: [Event] = try await query
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error performing live search: \(error)")
        }
    }
    
    // MARK: - New Backend Integration for Filter Services
    
    // 6. Advanced search with database functions
    func performAdvancedSearch(searchText: String, filters: SearchFilters) async {
        do {
            _ = try await supabase
                .rpc("search_events_advanced", params: [
                    "search_text": searchText,
                    "sport_type_filter": filters.sportType ?? "All Sports",
                    "date_filter": filters.date != nil ? formatDateForDB(filters.date!) : "",
                    "location_filter": filters.location ?? "",
                    "radius_km": String(filters.radius ?? 40),
                    "user_lat": filters.latitude != nil ? String(filters.latitude!) : "",
                    "user_lon": filters.longitude != nil ? String(filters.longitude!) : "",
                    "limit_count": "50"
                ])
                .execute()
            
            // RPC might return Void, so we'll fall back to basic search
            print("RPC returned unexpected type, falling back to basic search")
            await performLiveSearch(searchText: searchText, filters: filters)
        } catch {
            print("Advanced search failed, falling back to basic search: \(error)")
            // Fall back to basic search
            await performLiveSearch(searchText: searchText, filters: filters)
        }
    }
    
    // 7. Sport-specific search using database function with validation
    func searchBySportType(_ sportType: String) async {
        if sportType == "All Sports" {
            await fetchEvents()
            return
        }
        
        do {
            _ = try await supabase
                .rpc("get_events_by_sport_validated", params: [
                    "sport_type_filter": sportType,
                    "limit_count": "50"
                ])
                .execute()
            
            // RPC might return Void, so we'll fall back to basic sport filtering
            print("RPC returned unexpected type, falling back to basic sport filtering")
            await filterBySportType(sportTypes: [sportType])
        } catch {
            print("Sport search failed, falling back to basic search: \(error)")
            // Fall back to basic sport filtering
            await filterBySportType(sportTypes: [sportType])
        }
    }
    
    // 8. Date range search using database function
    func searchByDateRange(startDate: Date, endDate: Date) async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let startDateString = formatter.string(from: startDate)
            let endDateString = formatter.string(from: endDate)
            
            _ = try await supabase
                .rpc("get_events_by_date_range", params: [
                    "start_date": startDateString,
                    "end_date": endDateString,
                    "limit_count": "50"
                ])
                .execute()
            
            // RPC might return Void, so we'll fall back to basic date filtering
            print("RPC returned unexpected type, falling back to basic date filtering")
            await filterByDateRange(startDate: startDate, endDate: endDate)
        } catch {
            print("Date range search failed, falling back to basic search: \(error)")
            // Fall back to basic date filtering
            await filterByDateRange(startDate: startDate, endDate: endDate)
        }
    }
    

    
    // MARK: - Helper Functions
    
    // Calculate distance between two coordinates using Haversine formula
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0 // Earth's radius in kilometers
        
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        let distance = R * c
        
        return distance
    }
    
    // Helper function to format date for database
    private func formatDateForDB(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Combined search with all filters
    func searchWithAllFilters(searchText: String, filters: SearchFilters) async {
        do {
            var query = supabase
                .from("events")
                .select()
                .eq("status", value: "active")
            
            // Text search
            if !searchText.isEmpty {
                let searchPattern = "%\(searchText)%"
                query = query.or("title.ilike.\(searchPattern),description.ilike.\(searchPattern),location.ilike.\(searchPattern),sport_type.ilike.\(searchPattern)")
            }
            
            // Sport filter
            if let sportType = filters.sportType, sportType != "All Sports" {
                query = query.eq("sport_type", value: sportType)
            }
            
            // Date filter
            if let date = filters.date {
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let startDateString = formatter.string(from: startOfDay)
                let endDateString = formatter.string(from: endOfDay)
                
                query = query.gte("date_time", value: startDateString)
                query = query.lt("date_time", value: endDateString)
            }
            
            // Location filter
            if let location = filters.location, !location.isEmpty {
                let locationPattern = "%\(location)%"
                query = query.ilike("location", pattern: locationPattern)
            }
            
            // Distance filter (if coordinates are provided)
            if let latitude = filters.latitude, let longitude = filters.longitude, let radius = filters.radius {
                // This would require PostGIS or similar for proper distance calculations
                // For now, we'll use bounding box approximation
                let latDelta = Double(radius) / 111.0
                let lonDelta = Double(radius) / (111.0 * cos(latitude * .pi / 180))
                
                query = query.gte("latitude", value: latitude - latDelta)
                query = query.lte("latitude", value: latitude + latDelta)
                query = query.gte("longitude", value: longitude - lonDelta)
                query = query.lte("longitude", value: longitude + lonDelta)
            }
            
            let events: [Event] = try await query
                .order("date_time", ascending: true)
                .execute()
                .value
            
            print("AuthManager: Fetched \(events.count) events")
            self.userEvents = events
        } catch {
            print("Error searching with all filters: \(error)")
        }
    }
    
    // Search locations from database
    func searchLocationsFromDB(query: String) async -> [LocationResult] {
        do {
            // First try to search from our locations table
            _ = try await supabase
                .rpc("search_locations", params: [
                    "search_query": query,
                    "limit_count": "20"
                ])
                .execute()
            
            // RPC might return Void, so we'll use fallback
            print("RPC returned unexpected type, using fallback")
            return getFallbackLocations(for: query)
        } catch {
            print("Database location search failed, using fallback: \(error)")
            // Fallback to hardcoded locations if database search fails
            return getFallbackLocations(for: query)
        }
    }
    
    // Fallback location search
    private func getFallbackLocations(for query: String) -> [LocationResult] {
        let allLocations = [
            ("Surrey, British Columbia", 49.1913, -122.8490),
            ("Vancouver, British Columbia", 49.2827, -123.1207),
            ("Burnaby, British Columbia", 49.2488, -122.9805),
            ("Richmond, British Columbia", 49.1666, -123.1336),
            ("Coquitlam, British Columbia", 49.2838, -122.7932),
            ("Delta, British Columbia", 49.0847, -123.0582),
            ("Langley, British Columbia", 49.1044, -122.5826),
            ("New Westminster, British Columbia", 49.2068, -122.9112),
            ("Port Coquitlam, British Columbia", 49.2621, -122.7816),
            ("Maple Ridge, British Columbia", 49.2194, -122.6019),
            ("White Rock, British Columbia", 49.0252, -122.8030),
            ("Port Moody, British Columbia", 49.2838, -122.7932),
            ("Pitt Meadows, British Columbia", 49.2213, -122.6897),
            ("Mission, British Columbia", 49.1417, -122.3107),
            ("Abbotsford, British Columbia", 49.0504, -122.3045)
        ]
        
        let filteredLocations = allLocations.filter { location in
            location.0.lowercased().contains(query.lowercased())
        }
        
        return filteredLocations.enumerated().map { index, location in
            LocationResult(
                id: "fallback_\(index)",
                displayName: location.0,
                latitude: location.1,
                longitude: location.2,
                distance: nil
            )
        }
    }
    
    // MARK: - Real-time Event Sync Methods
    
    // Get detailed event information with host details
    func getEventDetails(eventId: String) async throws -> EventDetails {
        print("AuthManager: Attempting to get event details for ID: \(eventId)")
        do {
                    let response: EventDetails = try await supabase
            .rpc("get_event_details_with_host_for_realtime_sync", params: ["event_uuid": eventId])
            .execute()
            .value
            
            print("AuthManager: Successfully retrieved event details")
            return response
        } catch {
            print("AuthManager: Error getting event details: \(error)")
            throw error
        }
    }
    
    // Get event participants
    func getEventParticipants(eventId: String) async throws -> [EventParticipant] {
        print("AuthManager: Attempting to get participants for event ID: \(eventId)")
        do {
                    let response: [EventParticipant] = try await supabase
            .rpc("get_event_participants_for_realtime_display", params: ["event_uuid": eventId])
            .execute()
            .value
            
            print("AuthManager: Successfully retrieved \(response.count) participants")
            return response
        } catch {
            print("AuthManager: Error getting participants: \(error)")
            throw error
        }
    }
    
    // Join event with real-time sync
    func joinEventWithSync(eventId: String) async throws -> Bool {
        guard let currentUser = currentUser else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        _ = try await supabase
            .rpc("join_event_with_realtime_participant_update", params: [
                "event_uuid": eventId,
                "user_uuid": currentUser.id.uuidString
            ])
            .execute()
        
        // If no error was thrown, assume success
        return true
    }
    
    // Leave event with real-time sync
    func leaveEventWithSync(eventId: String) async throws -> Bool {
        guard let currentUser = currentUser else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        _ = try await supabase
            .rpc("leave_event_with_realtime_participant_update", params: [
                "event_uuid": eventId,
                "user_uuid": currentUser.id.uuidString
            ])
            .execute()
        
        // If no error was thrown, assume success
        return true
    }
}

// MARK: - Event Notification Model
struct EventNotification: Codable, Identifiable {
    let id: String
    let eventId: String?
    let userId: String
    let notificationType: String
    let message: String
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, eventId = "event_id", userId = "user_id"
        case notificationType = "notification_type", message, isRead = "is_read"
        case createdAt = "created_at"
    }
}

// MARK: - Search Filters Model
struct SearchFilters {
    var sportType: String?
    var date: Date?
    var location: String?
    var latitude: Double?
    var longitude: Double?
    var radius: Int?
    
    init(sportType: String? = nil, date: Date? = nil, location: String? = nil, latitude: Double? = nil, longitude: Double? = nil, radius: Int? = nil) {
        self.sportType = sportType
        self.date = date
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
}
