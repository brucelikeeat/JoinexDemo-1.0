//
//  ExploreView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ExploreView: View {
    @Binding var selectedTab: Int
    @State private var searchText = ""
    @State private var selectedSport = "All Sports"
    @State private var navigateToEventDetail = false
    @State private var selectedDateIndex = 0
    @State private var selectedDistance = 10
    @State private var showLocationSheet = false
    @State private var locationText = "Surrey, British Columbia"
    @State private var radius = 40
    
    let sports = ["All Sports", "Badminton", "Tennis", "Basketball", "Soccer", "Running"]
    let distances = [1, 5, 10, 25, 40, 50] // km
    let dateLabels: [String] = {
        let calendar = Calendar.current
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return (0..<5).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: today)!
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
            let date = calendar.date(byAdding: .day, value: offset, to: today)!
            return formatter.string(from: date)
        }
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ZStack {
                        Text("Explore")
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        HStack {
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
                                    .fill(Color.blue)
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
                                .textFieldStyle(PlainTextFieldStyle())
                            
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
                        
                        // Location/Distance filter (centered, full width, clickable)
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
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Date selector
                        HStack(spacing: 12) {
                            ForEach(0..<5) { i in
                                Button(action: {
                                    selectedDateIndex = i
                                }) {
                                    VStack(spacing: 4) {
                                        Text(dateLabels[i])
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedDateIndex == i ? .white : .gray)
                                        Text(dateNumbers[i])
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(selectedDateIndex == i ? .white : .black)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedDateIndex == i ? Color.blue : Color.gray.opacity(0.08))
                                    .cornerRadius(16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 2)
                        
                        // Sport filter
                        ScrollViewReader { scrollProxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(sports, id: \.self) { sport in
                                        Button(action: {
                                            withAnimation(.easeInOut) {
                                                selectedSport = sport
                                                scrollProxy.scrollTo(sport, anchor: .center)
                                            }
                                        }) {
                                            Text(sport)
                                                .font(.system(size: 14, weight: .medium, design: .default))
                                                .foregroundColor(selectedSport == sport ? .white : .black)
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(selectedSport == sport ? Color.blue : Color.gray.opacity(0.1))
                                                .cornerRadius(20)
                                        }
                                        .id(sport)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Events List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sampleEvents, id: \.id) { event in
                                ExploreEventCard(event: event) {
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
                EventDetailView()
            }
            .navigationBarHidden(true)
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
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        // Status badge
                        Text(event.status)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(event.statusColor)
                            .cornerRadius(12)
                    }
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(event.date)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(event.location)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text("\(event.playersCount) / \(event.maxPlayers) players")
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(event.skillLevel)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Event {
    let id = UUID()
    let title: String
    let date: String
    let location: String
    let playersCount: Int
    let maxPlayers: Int
    let skillLevel: String
    let status: String
    let statusColor: Color
}

let sampleEvents = [
    Event(title: "UBC Badminton Centre", date: "Today, 2:00 PM", location: "Vancouver, BC", playersCount: 6, maxPlayers: 8, skillLevel: "Intermediate", status: "Open", statusColor: .green),
    Event(title: "Richmond Ace Badminton", date: "Tomorrow, 10:00 AM", location: "Richmond, BC", playersCount: 8, maxPlayers: 8, skillLevel: "Beginner", status: "Full", statusColor: .red),
    Event(title: "Community Tennis", date: "Sep 25, 2025", location: "Stanley Park", playersCount: 3, maxPlayers: 4, skillLevel: "Advanced", status: "Open", statusColor: .green),
    Event(title: "Basketball Pickup", date: "Sep 26, 2025", location: "Local Gym", playersCount: 8, maxPlayers: 10, skillLevel: "All Levels", status: "Open", statusColor: .green)
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
                        .background(Color.blue)
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
} 
