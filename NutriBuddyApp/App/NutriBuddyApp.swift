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


// MARK: - Main App View
struct MainAppView: View {
    @Query private var profiles: [UserProfile]
    @State private var showOnboarding = false
    @State private var showingAddFood = false
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var context

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView {
                    showOnboarding = false
                }
            } else {
                ZStack {
                    TabView(selection: $selectedTab) {
                        MainView()
                            .tabItem {
                                Label("Food", systemImage: "list.bullet")
                            }
                            .tag(0)
                        
                        ProfileView()
                            .tabItem {
                                Label("Profile", systemImage: "person.circle")
                            }
                            .tag(1)
                    }
                    .accentColor(.blue)
                    
                    // MARK: - Floating Add Food Button (Only on Food Tab)
                    if selectedTab == 0 {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                  
                                    showingAddFood = true
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 64, height: 64)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gradientStart, Color.gradientEnd]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Circle())
                                        .shadow(radius: 6, y: 3)
                                }
                                .offset(y: -20)
                                Spacer()
                            }
                        }
                        .transition(.scale)
                        .animation(.easeInOut, value: selectedTab)
                    }
                }
                .sheet(isPresented: $showingAddFood) {
                    AddFoodView(
                        selectedDate: Date(),
                        context: context
                    )
                }
                .onAppear {
                    showOnboarding = profiles.isEmpty
                }
                
            }
        }
    }
}

