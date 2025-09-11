//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.

import SwiftUI
import SwiftData

struct MainView: View {
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
            ScrollView {
                VStack(spacing: 20) {
                
                    VStack(spacing: 16) {
                        if progressViewModel.hasProfile {
                            CalorieProgressCard(
                                viewModel: progressViewModel.calorieProgressViewModel,
                                steps: progressViewModel.stepsToday,
                                stepGoal: progressViewModel.stepGoal
                            )
                            
                            LazyVGrid(columns: macroColumns, spacing: 16) {
                                ForEach(progressViewModel.macroProgressViewModel.macros, id: \.title) { macro in
                                    MacroProgressCard(macro: macro)
                                }
                            }
                            
                            if healthKitManager.isAuthorized {
                                StepsCardView(
                                    steps: progressViewModel.stepsToday,
                                    goal: progressViewModel.stepGoal,
                                    isRefreshing: false,
                                    onRefresh: {
                                        progressViewModel.refreshSteps(using: healthKitManager, force: true)
                                    }
                                )
                            }
                        } else {
                            NoProfileCard()
                        }
                    }
                    
                  
                    VStack(spacing: 12) {
                        if !foodListViewModel.dailyFoods.isEmpty {
                            FoodLogHeaderCard(foodCount: foodListViewModel.dailyFoods.count)
                            
                            List {
                                ForEach(foodListViewModel.dailyFoods, id: \.id) { food in
                                    FoodItemCard(food: food)
                                        .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                                .onDelete { indexSet in
                                    indexSet.forEach { index in
                                        let food = foodListViewModel.dailyFoods[index]
                                        withAnimation {
                                            foodListViewModel.deleteFood(food)
                                            scheduleProgressUpdate()
                                        }
                                    }
                                }
                            }
                            .listStyle(.plain)
                            .frame(height: CGFloat(foodListViewModel.dailyFoods.count * 70))
                            .scrollDisabled(true)
                            .background(Color.clear)
                            
                      
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
                            .padding(.top, 16)
                        } else {
                            EmptyFoodLogView(onAddFood: { showingAddFood = true })
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .background(Color.appBackground)
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
                refreshViewModelsFromQueries()
            }
            .onChange(of: allFoods) { _, _ in
                foodListViewModel.updateFoods(allFoods, context: context)
                scheduleProgressUpdate()
            }
            .onChange(of: profiles) { _, _ in
                foodListViewModel.updateProfiles(profiles)
                scheduleProgressUpdate()
            }
            .onChange(of: foodListViewModel.selectedDate) { _, _ in
                scheduleProgressUpdate()
            }
            .onChange(of: healthKitManager.isAuthorized) { _, isAuthorized in
                if isAuthorized {
                    progressViewModel.refreshSteps(using: healthKitManager, force: true)
                }
            }
        }
    }
    
    private var macroColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
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
    
    private var dateText: String {
        DateFormatter.dateLabel(for: foodListViewModel.selectedDate)
    }
    
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

