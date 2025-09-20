import SwiftUI

struct SportSearchView: View {
    @Binding var selectedSport: String
    let onSportSelected: () -> Void
    
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [String] = []
    @State private var isSearching = false
    @State private var searchDebounceTimer: Timer?
    
    // Comprehensive sports list
    let allSports = [
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        print("SportSearchView: Cancel button pressed")
                        dismiss()
                    }
                    .foregroundColor(.royalBlue)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    
                    Spacer()
                    
                    Text("Select Sport")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                    
                    Spacer()
                    
                    Button("Done") {
                        print("SportSearchView: Done button pressed")
                        onSportSelected()
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
                    
                    TextField("Search for a sport...", text: $searchText)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .onChange(of: searchText) { _, newValue in
                            performSportSearch()
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
                    ProgressView("Searching sports...")
                        .foregroundColor(.gray)
                    Spacer()
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "sportscourt")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No sports found")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(.gray)
                        
                        Text("Try a different search term")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else if searchResults.isEmpty && searchText.isEmpty {
                    // Show all sports
                    VStack(alignment: .leading, spacing: 16) {
                        Text("All Sports")
                            .font(.system(size: 18, weight: .semibold, design: .default))
                            .padding(.horizontal, 20)
                        
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(allSports, id: \.self) { sport in
                                    Button(action: {
                                        selectedSport = sport
                                        onSportSelected()
                                        dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "sportscourt")
                                                .foregroundColor(.royalBlue)
                                                .font(.system(size: 16))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(sport)
                                                    .font(.system(size: 16, weight: .medium, design: .default))
                                                    .foregroundColor(.black)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedSport == sport {
                                                Image(systemName: "checkmark")
                                                    .foregroundColor(.royalBlue)
                                                    .font(.system(size: 16))
                                            }
                                            
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
                                                .stroke(selectedSport == sport ? Color.royalBlue : Color.gray.opacity(0.2), lineWidth: selectedSport == sport ? 2 : 1)
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
                            ForEach(searchResults, id: \.self) { sport in
                                Button(action: {
                                    selectedSport = sport
                                    onSportSelected()
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "sportscourt")
                                            .foregroundColor(.royalBlue)
                                            .font(.system(size: 16))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(sport)
                                                .font(.system(size: 16, weight: .medium, design: .default))
                                                .foregroundColor(.black)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        if selectedSport == sport {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.royalBlue)
                                                .font(.system(size: 16))
                                        }
                                        
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
                                            .stroke(selectedSport == sport ? Color.royalBlue : Color.gray.opacity(0.2), lineWidth: selectedSport == sport ? 2 : 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func performSportSearch() {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
            Task {
                await searchSports()
            }
        }
    }
    
    private func searchSports() async {
        guard !searchText.isEmpty else {
            await MainActor.run {
                searchResults = []
            }
            return
        }
        
        await MainActor.run {
            isSearching = true
        }
        
        // Filter sports based on search text
        let filteredSports = allSports.filter { sport in
            sport.lowercased().contains(searchText.lowercased())
        }
        
        await MainActor.run {
            searchResults = filteredSports
            isSearching = false
        }
    }
} 