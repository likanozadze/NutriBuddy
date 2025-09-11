//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query private var allFoods: [FoodEntry]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    @State private var foodListViewModel = FoodListViewModel()
    @State private var progressViewModel = ProgressViewModel()
    @EnvironmentObject private var healthKitManager: HealthKitManager
    
    @State private var progressUpdateTask: Task<Void, Never>?
    @State private var showingAddFood = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                List {
                    Section {
                        DailySummaryView(viewModel: progressViewModel)
                    }
                    
                    Section {
                        if foodListViewModel.dailyFoods.isEmpty {
                            EmptyFoodLogView(onAddFood: { showingAddFood = true })
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.appBackground)
                        } else {
                            ForEach(foodListViewModel.dailyFoods, id: \.id) { food in
                                FoodItemCard(food: food)
                                    .listRowSeparator(.hidden)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let food = foodListViewModel.dailyFoods[index]
                                    foodListViewModel.deleteFood(food)
                                    scheduleProgressUpdate()
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color.appBackground)
                
    
                if !foodListViewModel.dailyFoods.isEmpty {
                    Button(action: { showingAddFood = true }) {
                        HStack {
                            Text("Add Food")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color.appBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.calorieCardButtonBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    dateNavigationBar
                }
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(
                    selectedDate: foodListViewModel.selectedDate,
                    context: context
                )
            }
            .onAppear {
                print("FoodListView appeared")
                refreshViewModelsFromQueries()
            }
            .onChange(of: allFoods) { _, _ in
                print("AllFoods changed, updating foods")
                foodListViewModel.updateFoods(allFoods, context: context)
                scheduleProgressUpdate()
            }
            .onChange(of: profiles) { _, _ in
                print("Profiles changed, updating profiles")
                foodListViewModel.updateProfiles(profiles)
                scheduleProgressUpdate()
            }
            .onChange(of: foodListViewModel.selectedDate) { _, _ in
                print("Selected date changed: \(foodListViewModel.selectedDate)")
                scheduleProgressUpdate()
            }
            .onChange(of: healthKitManager.isAuthorized) { _, isAuthorized in
                if isAuthorized {
                    print("HealthKit authorized, fetching steps")
                    progressViewModel.refreshSteps(using: healthKitManager, force: true)
                }
            }
        }
    }
    
    // MARK: - Date Navigation Bar
    private var dateNavigationBar: some View {
        HStack {
            Button {
                foodListViewModel.navigateDate(by: -1)
                scheduleProgressUpdate()
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
                scheduleProgressUpdate()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Date Text
    private var dateText: String {
        DateFormatter.dateLabel(for: foodListViewModel.selectedDate)
    }
    
    // MARK: - Helpers
    @MainActor
    private func refreshViewModelsFromQueries() {
        foodListViewModel.updateFoods(allFoods, context: context)
        foodListViewModel.updateProfiles(profiles)
        scheduleProgressUpdate()
    }
    
    private func scheduleProgressUpdate() {
        progressUpdateTask?.cancel()
        
        let currentDate = foodListViewModel.selectedDate
        let foodsSnapshot = allFoods
        let profile = foodListViewModel.currentProfile
        
        progressUpdateTask = Task { @MainActor in
            let dailyFoods = await Task.detached(priority: .userInitiated) {
                NutritionCalculator.filterFoodsForDate(foodsSnapshot, date: currentDate)
            }.value
            
            progressViewModel.updateData(foods: dailyFoods, profile: profile)
            
            if Calendar.current.isDateInToday(currentDate) {
                progressViewModel.refreshSteps(using: healthKitManager)
            } else {
                progressViewModel.stepsToday = 0
            }
        }
    }
}
