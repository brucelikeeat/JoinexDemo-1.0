//
//  MainTabView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("Explore")
                }
                .tag(1)
            
            HostView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Host")
                }
                .tag(2)
            
            MessagesView()
                .tabItem {
                    Image(systemName: "message")
                    Text("Message")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
} 