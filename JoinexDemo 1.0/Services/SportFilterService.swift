import Foundation
import SwiftUI

class SportFilterService: ObservableObject {
    @Published var selectedSport = "All Sports"
    @Published var showSportDropdown = false
    
    let sports = [
        "All Sports",
        "General (Casual/Any)",
        "Badminton",
        "Basketball",
        "Soccer (Football)",
        "Volleyball",
        "Table Tennis",
        "Tennis",
        "Pickleball",
        "Baseball",
        "Softball",
        "Running",
        "Cycling",
        "Swimming",
        "Climbing (Indoor/Outdoor)",
        "Skating (Ice/Roller)",
        "Skiing/Snowboarding",
        "Golf",
        "Ultimate Frisbee",
        "Flag Football",
        "Martial Arts (e.g., Judo, Taekwondo)",
        "Boxing",
        "Wrestling",
        "Dance Fitness (Zumba, Hip-Hop, etc.)",
        "Yoga/Pilates",
        "CrossFit/HIIT/Bootcamp",
        "Esports/Gaming Tournaments",
        "Dodgeball",
        "Cricket",
        "Rugby",
        "Lacrosse",
        "Hockey (Field/Ice)",
        "Surfing",
        "Archery",
        "Rowing",
        "Bouldering",
        "Kendo/Fencing",
        "Cheerleading",
        "Horseback Riding"
    ]
    
    private var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func toggleSportDropdown() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSportDropdown.toggle()
        }
    }
    
    func selectSport(_ sport: String) {
        selectedSport = sport
        showSportDropdown = false
    }
    
    func isSportSelected(_ sport: String) -> Bool {
        return selectedSport == sport
    }
    
    func clearSportFilter() {
        selectedSport = "All Sports"
    }
} 
