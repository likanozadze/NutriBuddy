//
//  NutriBuddyAppApp.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

@main
struct NutriBuddyApp: App {
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
        .modelContainer(for: [FoodEntry.self, UserProfile.self])
    }
}

struct MainAppView: View {
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false
    
    var body: some View {
        TabView {
        Group {
            if profiles.isEmpty {
                OnboardingView {
                   
                    showOnboarding = false
                }
            } else {
                FoodListView()
            }
        }
        
        .tabItem {
                       Label("Food", systemImage: "list.bullet")
                   }
                   
                   ProfileView()
                       .tabItem {
                           Label("Profile", systemImage: "person.circle")
                       }
               }
    
        .onAppear {
            showOnboarding = profiles.isEmpty
        }
    }
}
