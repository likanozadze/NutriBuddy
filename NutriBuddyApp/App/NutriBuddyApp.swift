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
    @StateObject private var healthKitManager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(healthKitManager)
        }
        .modelContainer(for: [FoodEntry.self, UserProfile.self])
    }
}

struct MainAppView: View {
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
     
                TabView {
                  
                    MainView()
                        .tabItem {
                            Label("Food", systemImage: "list.bullet")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                }
                .accentColor(.blue) 
            }
        }
        .onAppear {
            showOnboarding = profiles.isEmpty
        }
    }
}
