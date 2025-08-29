//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//
//
import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query private var allFoods: [FoodEntry]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    @State private var foodListViewModel = FoodListViewModel()
    @State private var progressViewModel = ProgressViewModel()
    @StateObject private var healthKitManager = HealthKitManager()
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DailySummaryView(viewModel: progressViewModel)
                    StepProgressRing(
                        steps: progressViewModel.stepsToday,
                        goal: 10000,
                        ringColor: .customBlue
                    )
                    .padding(12)
                    .background(Color.listBackground.opacity(0.5))
                    .cornerRadius(12)
                    
                    
                    FoodListSection(
                        foods: foodListViewModel.dailyFoods,
                        selectedDate: foodListViewModel.selectedDate
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
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
                setupViewModels()
            }
            .onChange(of: allFoods) { _, _ in setupViewModels() }
            .onChange(of: profiles) { _, _ in setupViewModels() }
            .onChange(of: foodListViewModel.selectedDate) { _, _ in updateProgressData() }
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
        healthKitManager.fetchTodaySteps { steps in
            progressViewModel.stepsToday = Int(steps)
        }
    }
}
