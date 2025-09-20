import Foundation
import SwiftUI
import CoreLocation

class LocationFilterService: ObservableObject {
    @Published var selectedLocation = "Surrey, British Columbia"
    @Published var selectedRadius = 40
    @Published var isLocationFilterActive = false
    
    private var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func selectLocation(_ location: String) {
        selectedLocation = location
        isLocationFilterActive = location != "Surrey, British Columbia"
    }
    
    func selectRadius(_ radius: Int) {
        selectedRadius = radius
    }
    
    func clearLocationFilter() {
        selectedLocation = "Surrey, British Columbia"
        selectedRadius = 40
        isLocationFilterActive = false
    }
} 