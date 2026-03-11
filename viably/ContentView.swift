//
//  ContentView.swift
//  viably
//
//  Created by Ruitao Chen on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            SocialFeedView()
                .tabItem {
                    Label("Feed", systemImage: "flame.fill")
                }
                .tag(1)

            NavigationStack {
                MyHabitsView()
            }
            .tabItem {
                Label("Create", systemImage: "plus.circle.fill")
            }
            .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.dsAccentLime)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
