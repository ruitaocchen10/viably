//
//  ContentView.swift
//  viably
//
//  Created by Ruitao Chen on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            SocialFeedView()
                .tabItem {
                    Label("Feed", systemImage: "flame.fill")
                }

            CreationView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.dsAccentLime)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
