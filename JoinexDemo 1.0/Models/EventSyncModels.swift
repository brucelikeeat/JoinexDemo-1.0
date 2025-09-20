import Foundation

// MARK: - Event Details Model
struct EventDetails: Codable, Identifiable {
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
    let status: String
    let createdAt: Date
    let updatedAt: Date
    let hostEmail: String?
    let hostFullName: String?
    let hostAvatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, sportType = "sport_type", location, latitude, longitude
        case dateTime = "date_time", durationMinutes = "duration_minutes", maxPlayers = "max_players"
        case currentPlayers = "current_players", skillLevel = "skill_level", hostId = "host_id"
        case status, createdAt = "created_at", updatedAt = "updated_at"
        case hostEmail = "host_email", hostFullName = "host_full_name", hostAvatarUrl = "host_avatar_url"
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
    
    var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var hostInitials: String {
        guard let name = hostFullName, !name.isEmpty else {
            return hostEmail?.prefix(2).uppercased() ?? "H"
        }
        
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else {
            return name.prefix(2).uppercased()
        }
    }
    
    // Convenience initializer to create from Event
    init(from event: Event, hostEmail: String? = nil, hostFullName: String? = nil, hostAvatarUrl: String? = nil) {
        self.id = event.id
        self.title = event.title
        self.description = event.description
        self.sportType = event.sportType
        self.location = event.location
        self.latitude = event.latitude
        self.longitude = event.longitude
        self.dateTime = event.dateTime
        self.durationMinutes = event.durationMinutes
        self.maxPlayers = event.maxPlayers
        self.currentPlayers = event.currentPlayers
        self.skillLevel = event.skillLevel
        self.hostId = event.hostId
        self.status = event.status.rawValue
        self.createdAt = event.createdAt
        self.updatedAt = event.updatedAt
        self.hostEmail = hostEmail
        self.hostFullName = hostFullName ?? "Event Host"
        self.hostAvatarUrl = hostAvatarUrl
    }
}

// MARK: - Event Participant Model
struct EventParticipant: Codable, Identifiable {
    let id: String
    let email: String?
    let fullName: String?
    let avatarUrl: String?
    let joinedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id", email, fullName = "full_name"
        case avatarUrl = "avatar_url", joinedAt = "joined_at"
    }
    
    var displayName: String {
        fullName ?? email ?? "Unknown User"
    }
    
    var initials: String {
        guard let name = fullName, !name.isEmpty else {
            return email?.prefix(2).uppercased() ?? "U"
        }
        
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))".uppercased()
        } else {
            return name.prefix(2).uppercased()
        }
    }
} 