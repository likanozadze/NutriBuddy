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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DateNavigator(viewModel: foodListViewModel)
                    DailySummaryView(viewModel: progressViewModel)
                    FoodListSection(
                        foods: foodListViewModel.dailyFoods,
                        selectedDate: foodListViewModel.selectedDate,
                        onDelete: foodListViewModel.deleteFoods
                    )
                }
            }
            .padding(16)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.appBackground)
            .onAppear {
                setupViewModels()
            }
            .onChange(of: allFoods) { _, _ in setupViewModels() }
            .onChange(of: profiles) { _, _ in setupViewModels() }
            .onChange(of: foodListViewModel.selectedDate) { _, _ in updateProgressData() }
        }
    }
    
    private func setupViewModels() {
        foodListViewModel.setup(allFoods: allFoods, profiles: profiles, context: context)
        updateProgressData()
    }
    
    private func updateProgressData() {
        let dailyFoods = NutritionCalculator.filterFoodsForDate(
            allFoods,
            date: foodListViewModel.selectedDate
        )
        
        progressViewModel.updateData(
            foods: dailyFoods,
            profile: foodListViewModel.currentProfile
        )
    }
}
