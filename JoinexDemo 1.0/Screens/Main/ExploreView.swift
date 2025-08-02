//
//  ExploreView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ExploreView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authManager: AuthManager
    @State private var searchText = ""
    @State private var selectedSport = "All Sports"
    @State private var navigateToEventDetail = false
    @State private var selectedEvent: Event? = nil
    @State private var selectedDateIndex = 0
    @State private var selectedDistance = 10
    @State private var showLocationSheet = false
    @State private var locationText = "Surrey, British Columbia"
    @State private var radius = 40
    @State private var showFilters = false
    
    let sports = ["All Sports", "Badminton", "Tennis", "Basketball", "Soccer", "Running"]
    let distances = [1, 5, 10, 25, 40, 50] // km
    let dateLabels: [String] = {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return (0..<5).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            if offset == 0 { return "Today" }
            if offset == 1 { return "Tue" }
            return formatter.string(from: date)
        }
    }()
    let dateNumbers: [String] = {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return (0..<5).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            return formatter.string(from: date)
        }
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all, edges: .top)
                
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        HStack {
                            Image("logo1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Explore")
                                .font(.system(size: 16, weight: .bold, design: .default))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // Notification bell
                            Button(action: {
                                // Handle notifications
                            }) {
                                Image(systemName: "bell")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                            
                            // Profile picture
                            Button(action: {
                                selectedTab = 4
                            }) {
                                Circle()
                                    .fill(Color.royalBlue)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Text("BL")
                                            .font(.system(size: 12, weight: .bold, design: .default))
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Search and Filter
                    VStack(spacing: 16) {
                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search events...", text: $searchText)
                                .foregroundColor(.black)
                                .accentColor(.royalBlue)
                                .textFieldStyle(PlainTextFieldStyle())
                                .tint(.gray.opacity(0.9))
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Filter Toggle Button
                        Button(action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showFilters.toggle()
                            }
                        }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .foregroundColor(.royalBlue)
                                Text("Filters")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.royalBlue)
                                Spacer()
                                Image(systemName: showFilters ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.royalBlue)
                                    .font(.system(size: 14))
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // Collapsible Filters
                        if showFilters {
                            VStack(spacing: 12) {
                                // Sport Type Filter
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Sport Type")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    ScrollViewReader { scrollProxy in
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 12) {
                                                ForEach(sports, id: \.self) { sport in
                                                    Button(action: {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                            selectedSport = sport
                                                            scrollProxy.scrollTo(sport, anchor: .center)
                                                        }
                                                    }) {
                                                        Text(sport)
                                                            .font(.system(size: 14, weight: .medium))
                                                            .foregroundColor(selectedSport == sport ? .white : .royalBlue)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 8)
                                                            .background(selectedSport == sport ? Color.royalBlue : Color.clear)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 20)
                                                                    .stroke(Color.royalBlue, lineWidth: selectedSport == sport ? 0 : 1)
                                                            )
                                                            .cornerRadius(20)
                                                    }
                                                    .id(sport)
                                                }
                                            }
                                            .padding(.horizontal, 4)
                                        }
                                    }
                                }
                                
                                // Date Filter
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Date")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.black)
                                    
                                    HStack(spacing: 8) {
                                        ForEach(0..<5, id: \.self) { index in
                                            Button(action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                    selectedDateIndex = index
                                                }
                                            }) {
                                                VStack(spacing: 4) {
                                                    Text(dateNumbers[index])
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(selectedDateIndex == index ? .white : .black)
                                                    Text(dateLabels[index])
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(selectedDateIndex == index ? .white : .gray)
                                                }
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 12)
                                                .background(selectedDateIndex == index ? Color.royalBlue : Color.clear)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(Color.gray.opacity(0.3), lineWidth: selectedDateIndex == index ? 0 : 1)
                                                )
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                
                                // Location Filter
                                Button(action: { showLocationSheet = true }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundColor(.gray)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Location")
                                                .font(.system(size: 13, weight: .regular))
                                                .foregroundColor(.gray)
                                            Text(locationText)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.black)
                                        }
                                        Spacer()
                                        Text("• Within \(radius) kilometers")
                                            .font(.system(size: 13, weight: .regular))
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.95).combined(with: .opacity),
                                removal: .scale(scale: 0.95).combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Events List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(authManager.userEvents.isEmpty ? sampleEvents : authManager.userEvents, id: \.id) { event in
                                ExploreEventCard(event: event) {
                                    selectedEvent = event
                                    navigateToEventDetail = true
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                }
            }
            .sheet(isPresented: $showLocationSheet) {
                ChangeLocationView(locationText: $locationText, radius: $radius, distances: distances) {
                    showLocationSheet = false
                }
            }
            .navigationDestination(isPresented: $navigateToEventDetail) {
                if let selectedEvent = selectedEvent {
                    EventDetailView(event: selectedEvent)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await authManager.fetchEvents()
                }
            }
        }
    }
}

struct ExploreEventCard: View {
    let event: Event
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Event image
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "sportscourt")
                            .foregroundColor(.gray)
                            .font(.system(size: 40))
                    )
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(event.title)
                            .font(.system(size: 16, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        // Status badge
                        Text(event.status.displayName)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(event.status.color)
                            .cornerRadius(12)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.royalBlue)
                            .font(.caption)
                        
                        Text(event.formattedDateTime)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.royalBlue)
                            .font(.caption)
                        
                        Text(event.location)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.royalBlue)
                            .font(.caption)
                        
                        Text("\(event.currentPlayers) / \(event.maxPlayers) players")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(event.skillLevelText)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.royalBlue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.royalBlue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)

        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Sample events for preview (will be replaced with real events from database)
let sampleEvents: [Event] = [
    Event(
        id: "sample-1",
        title: "UBC Badminton Centre",
        description: "Join us for a fun badminton session!",
        sportType: "Badminton",
        location: "Vancouver, BC",
        latitude: nil,
        longitude: nil,
        dateTime: Date().addingTimeInterval(3600), // 1 hour from now
        durationMinutes: 120,
        maxPlayers: 8,
        currentPlayers: 6,
        skillLevel: 5,
        hostId: "sample-host-1",
        status: .active,
        createdAt: Date(),
        updatedAt: Date()
    ),
    Event(
        id: "sample-2",
        title: "Richmond Ace Badminton",
        description: "Advanced level badminton game",
        sportType: "Badminton",
        location: "Richmond, BC",
        latitude: nil,
        longitude: nil,
        dateTime: Date().addingTimeInterval(7200), // 2 hours from now
        durationMinutes: 120,
        maxPlayers: 8,
        currentPlayers: 8,
        skillLevel: 7,
        hostId: "sample-host-2",
        status: .active,
        createdAt: Date(),
        updatedAt: Date()
    ),
    Event(
        id: "sample-3",
        title: "Community Tennis",
        description: "All levels welcome!",
        sportType: "Tennis",
        location: "Stanley Park, Vancouver",
        latitude: nil,
        longitude: nil,
        dateTime: Date().addingTimeInterval(10800), // 3 hours from now
        durationMinutes: 90,
        maxPlayers: 4,
        currentPlayers: 3,
        skillLevel: 4,
        hostId: "sample-host-3",
        status: .active,
        createdAt: Date(),
        updatedAt: Date()
    )
]

struct ChangeLocationView: View {
    @Binding var locationText: String
    @Binding var radius: Int
    let distances: [Int]
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text("Change location")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
            Divider()
            // Search field
            HStack {
                                            TextField("Search by city, neighborhood or ZIP code.", text: $searchQuery)
                                .foregroundColor(.black)
                                .accentColor(.royalBlue)
                                .tint(.gray.opacity(0.9))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
            // Location box
            VStack(alignment: .leading, spacing: 2) {
                Text("Location")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(locationText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            // Radius box
            VStack(alignment: .leading, spacing: 2) {
                Text("Radius")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                Menu {
                    ForEach(distances, id: \.self) { d in
                        Button("\(d) kilometers") { radius = d }
                    }
                } label: {
                    HStack {
                        Text("\(radius) kilometers")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal, 16)
            .padding(.top, 12)
            // Current location and info icons
            HStack {
                Spacer()
                Button(action: {
                    // TODO: Use current location
                }) {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    // TODO: Show info
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.top, 24)
            Spacer()
            // Apply button
            HStack {
                Spacer()
                Button(action: {
                    onApply()
                }) {
                    Text("Apply")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.royalBlue)
                        .cornerRadius(12)
                }
                .padding(.bottom, 24)
                .padding(.trailing, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
    }
}

#Preview {
    ExploreView(selectedTab: .constant(0))
        .environmentObject(AuthManager())
} 
 
