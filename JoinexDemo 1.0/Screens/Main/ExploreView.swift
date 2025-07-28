//
//  ExploreView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct ExploreView: View {
    @State private var searchText = ""
    @State private var selectedSport = "All Sports"
    @State private var navigateToEventDetail = false
    @State private var selectedDateIndex = 0
    @State private var selectedDistance = 10
    
    let sports = ["All Sports", "Badminton", "Tennis", "Basketball", "Soccer", "Running"]
    let distances = [1, 5, 10, 25, 50] // km
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
                    HStack {
                        Button(action: {
                            // Handle back
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Explore")
                            .font(.system(size: 18, weight: .bold, design: .default))
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
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("BL")
                                    .font(.system(size: 12, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                            )
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
                        
                        // Location/Distance filter
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                Text("Vancouver")
                                    .font(.system(size: 15, weight: .medium))
                                Text("• Within \(selectedDistance) km")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            
                            Spacer()
                            
                            Button(action: {
                                // Open filter modal (to be implemented)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Filter")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 2)
                        
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

#Preview {
    ExploreView()
} 
