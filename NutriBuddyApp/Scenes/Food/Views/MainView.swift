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
            VStack(20) {
                List {
                    Section {
                        DailySummaryView(viewModel: progressViewModel)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.appBackground)

                    if !foodListViewModel.dailyFoods.isEmpty {
                        Section {
                            FoodLogHeaderCard(foodCount: foodListViewModel.dailyFoods.count)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.appBackground)

                            ForEach(foodListViewModel.dailyFoods, id: \.id) { food in
                                FoodItemCard(food: food)
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.appBackground)
                            }
                            .onDelete { indexSet in
                                indexSet.forEach { index in
                                    let food = foodListViewModel.dailyFoods[index]
                                    foodListViewModel.deleteFood(food)
                                    scheduleProgressUpdate()
                                }
                            }
                        }
                    } else {
                        Section {
                            EmptyFoodLogView(onAddFood: { showingAddFood = true })
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.appBackground)
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color.appBackground)
                .scrollContentBackground(.hidden)
                
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
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 16)
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

//struct FoodLogHeaderCard: View {
//    var foodCount: Int
//    
//    var body: some View {
//        HStack() {
//            Text("Food Log")
//                .font(.headline)
//                .foregroundColor(.primary)
//            Spacer()
//            Text("\(foodCount) item\(foodCount == 1 ? "" : "s") logged")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding(.vertical, 10)
//        .padding(.horizontal, 10)
//        .cornerRadius(12)
//        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
//    }
//}
struct FoodLogHeaderCard: View {
    var foodCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Food Log")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
                Text("\(foodCount) item\(foodCount == 1 ? "" : "s") logged")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
