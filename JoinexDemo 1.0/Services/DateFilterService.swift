import Foundation
import SwiftUI

class DateFilterService: ObservableObject {
    @Published var selectedDateIndex = 0
    @Published var isDateFilterActive = false
    
    private var authManager: AuthManager?
    
    func setAuthManager(_ authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func selectDateOption(_ index: Int) {
        selectedDateIndex = index
        isDateFilterActive = index != 0
    }
    
    func clearDateFilter() {
        selectedDateIndex = 0
        isDateFilterActive = false
    }
} 