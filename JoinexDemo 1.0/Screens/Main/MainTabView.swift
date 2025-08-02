//
//  MainTabView.swift
//  JoinexDemo 1.0
//
//  Created by Molin Liu on 2025/7/26.
//

import SwiftUI
import Supabase

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            ExploreTab(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "safari")
                    Text("Explore")
                }
                .tag(1)
            
            HostTab(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "target")
                    Text("Host")
                }
                .tag(2)
            
            MessagesTab(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "message")
                    Text("Message")
                }
                .tag(3)
            
            ProfileTab(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.royalBlue)
        .preferredColorScheme(.light)
        .onAppear {
            // Ensure consistent tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.white
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
            UITabBar.appearance().unselectedItemTintColor = UIColor.gray
            UITabBar.appearance().tintColor = UIColor(Color.royalBlue)
        }
    }
}

struct HomeTab: View {
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            HomeView(selectedTab: $selectedTab)
            // Add .navigationDestination(for:) as needed for Home subpages
        }
        .navigationBarHidden(true)
    }
}

struct ExploreTab: View {
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            ExploreView(selectedTab: $selectedTab)
            // Add .navigationDestination(for:) as needed for Explore subpages
        }
        .navigationBarHidden(true)
    }
}

struct HostTab: View {
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            HostView(selectedTab: $selectedTab)
            // Add .navigationDestination(for:) as needed for Host subpages
        }
        .navigationBarHidden(true)
    }
}

struct MessagesTab: View {
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            MessagesView(selectedTab: $selectedTab)
            // Add .navigationDestination(for:) as needed for Messages subpages
        }
        .navigationBarHidden(true)
    }
}

struct ProfileTab: View {
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            ProfileView(selectedTab: $selectedTab)
            // Add .navigationDestination(for:) as needed for Profile subpages
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    MainTabView()
} 
