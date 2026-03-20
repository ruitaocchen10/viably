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
                    AppLoadingView()
                } else if authVM.isAuthenticated, let userID = authVM.currentUserID {
                    ContentView(userID: userID)
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
