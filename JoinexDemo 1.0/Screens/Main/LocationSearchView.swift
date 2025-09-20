import SwiftUI
import CoreLocation

struct LocationSearchView: View {
    @Binding var locationText: String
    @Binding var radius: Int
    let distances: [Int]
    let onLocationSelected: () -> Void
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [LocationResult] = []
    @State private var isSearching = false
    @State private var searchDebounceTimer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        print("LocationSearchView: Cancel button pressed")
                        dismiss()
                    }
                    .foregroundColor(.royalBlue)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    
                    Spacer()
                    
                    Text("Select Location")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    
                    Spacer()
                    
                    Button("Done") {
                        print("LocationSearchView: Done button pressed")
                        onLocationSelected()
                        dismiss()
                    }
                    .foregroundColor(.royalBlue)
                    .fontWeight(.medium)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .bottom
                )
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    
                    TextField("Search for a location...", text: $searchText)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .onChange(of: searchText) { _, newValue in
                            performLocationSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Search Results
                if isSearching {
                    Spacer()
                    ProgressView("Searching locations...")
                        .foregroundColor(.gray)
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No locations found")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(.gray)
                        
                        Text("Try a different search term")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if searchResults.isEmpty && searchText.isEmpty {
                    // Show recent locations or popular locations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Popular Locations")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .padding(.horizontal, 20)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(popularLocations, id: \.self) { location in
                                    Button(action: {
                                        locationText = location
                                        onLocationSelected()
                                        dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "location")
                                                .foregroundColor(.royalBlue)
                                                .font(.system(size: 16))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(location)
                                                    .font(.system(size: 16, weight: .medium, design: .default))
                                                    .foregroundColor(.black)
                                                
                                                Text("Popular location")
                                                    .font(.system(size: 12, weight: .regular, design: .default))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 12))
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } else {
                    // Search Results
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults, id: \.id) { result in
                                Button(action: {
                                    locationText = result.displayName
                                    onLocationSelected()
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "location")
                                            .foregroundColor(.royalBlue)
                                            .font(.system(size: 16))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(result.displayName)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .foregroundColor(.black)
                                                .lineLimit(2)
                                            
                                            if let distance = result.distance {
                                                Text("\(String(format: "%.1f", distance)) km away")
                                                    .font(.system(size: 12, weight: .regular, design: .default))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 12))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
                
                // Radius Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Radius")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(distances, id: \.self) { distance in
                                Button(action: {
                                    radius = distance
                                }) {
                                    Text("\(distance) km")
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(radius == distance ? .white : .royalBlue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(radius == distance ? Color.royalBlue : Color.royalBlue.opacity(0.1))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 16)
                .background(Color.gray.opacity(0.05))
            }
        }
        .navigationBarHidden(true)
    }
    
    private func performLocationSearch() {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            Task {
                await searchLocations()
            }
        }
    }
    
    private func searchLocations() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            let results = await authManager.searchLocationsFromDB(query: searchText)
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
        }
    }
    
    private let popularLocations = [
        "Surrey, British Columbia",
        "Vancouver, British Columbia",
        "Burnaby, British Columbia",
        "Richmond, British Columbia",
        "Coquitlam, British Columbia",
        "Delta, British Columbia",
        "Langley, British Columbia",
        "New Westminster, British Columbia",
        "Port Coquitlam, British Columbia",
        "Maple Ridge, British Columbia"
    ]
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