//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query private var allFoods: [FoodEntry]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    @State private var foodListViewModel = FoodListViewModel()
    @State private var progressViewModel = ProgressViewModel()
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DailySummaryView(viewModel: progressViewModel)
                    
                    FoodListSection(
                        foods: foodListViewModel.dailyFoods,
                        selectedDate: foodListViewModel.selectedDate
                    )
                }
            }
            .padding(.horizontal, 16)
            .scrollIndicators(.hidden)
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Button {
                            foodListViewModel.navigateDate(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        
                        Text(dateText)
                            .font(.headline)
                            .frame(minWidth: 120)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            foodListViewModel.navigateDate(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .onAppear {
                print("FoodListView appeared")
                setupViewModels()
            }
            .onChange(of: allFoods) { _, _ in
                print("AllFoods changed, updating view models")
                setupViewModels()
            }
            .onChange(of: profiles) { _, _ in
                print("Profiles changed, updating view models")
                setupViewModels()
            }
            .onChange(of: foodListViewModel.selectedDate) { _, _ in
                print("Selected date changed: \(foodListViewModel.selectedDate)")
                updateProgressData()
            }
            .onChange(of: healthKitManager.isAuthorized) { _, isAuthorized in
                if isAuthorized {
                    print("HealthKit authorized, fetching steps")
                    updateProgressData()
                }
            }
        }
    }
    
    private var dateText: String {
        let calendar = Calendar.current
        let selectedDate = foodListViewModel.selectedDate
        
        if calendar.isDateInToday(selectedDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: selectedDate)
        }
    }
    
    private func setupViewModels() {
        print("Setting up view models")
        foodListViewModel.setup(allFoods: allFoods, profiles: profiles, context: context)
        updateProgressData()
    }
    
    private func updateProgressData() {
        print("Updating progress data")
        let dailyFoods = NutritionCalculator.filterFoodsForDate(
            allFoods,
            date: foodListViewModel.selectedDate
        )
        
        progressViewModel.updateData(
            foods: dailyFoods,
            profile: foodListViewModel.currentProfile
        )
        
        if Calendar.current.isDateInToday(foodListViewModel.selectedDate) {
            print("Fetching steps for today")
            healthKitManager.fetchTodayStepsWithCaching { steps in
                print("Received steps: \(steps)")
                progressViewModel.stepsToday = Int(steps)
            }
        } else {
            progressViewModel.stepsToday = 0
        }
    }
}
