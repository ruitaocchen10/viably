//
//  viablyApp.swift
//  viably
//
//  Created by Ruitao Chen on 3/9/26.
//

import SwiftUI
import Supabase

@main
struct viablyApp: App {
    @StateObject var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isCheckingSession {
                    Color.clear
                } else if authVM.isAuthenticated {
                    ContentView()
                        .environmentObject(authVM)
                } else {
                    AuthView()
                        .environmentObject(authVM)
                }
            }
            .onOpenURL { url in
                Task {
                    try? await supabase.auth.session(from: url)
                }
            }
        }
    }
}
