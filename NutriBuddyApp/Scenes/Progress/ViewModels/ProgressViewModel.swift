//
//  ProgressViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//


import SwiftUI
// MARK: - ProgressViewModel
@MainActor
class ProgressViewModel: ObservableObject {
    @Published var calorieProgressViewModel = CalorieProgressViewModel()
    @Published var macroProgressViewModel = MacroProgressViewModel()
    @Published private(set) var hasProfile = false
    private var isFetchingSteps = false

    @Published var stepsToday: Int = 0 {
        didSet {
            print("ProgressViewModel: steps updated to \(stepsToday)")
        }
    }
    @Published var stepGoal: Int = 10000
    
    func updateData(foods: [FoodEntry], profile: UserProfile?) {
        guard let profile = profile else {
            hasProfile = false
            updateEmptyProgress()
            return
        }
        
        hasProfile = true
        updateProgressWithProfile(foods: foods, profile: profile)
    }
    
    private func updateEmptyProgress() {
        let emptyProgress = CalorieProgress(target: 0, eaten: 0, remaining: 0)
        calorieProgressViewModel.updateProgress(emptyProgress)
        macroProgressViewModel.updateMacros([])
    }
    
    private func updateProgressWithProfile(foods: [FoodEntry], profile: UserProfile) {
        let totalCalories = NutritionCalculator.calculateTotalCalories(from: foods)
        let totalProtein = NutritionCalculator.calculateTotalProtein(from: foods)
        let totalCarbs = NutritionCalculator.calculateTotalCarbs(from: foods)
        let totalFats = NutritionCalculator.calculateTotalFat(from: foods)
        let totalFiber = NutritionCalculator.calculateTotalFiber(from: foods)
        
        let calorieProgress = CalorieProgress(
            target: profile.dailyCalorieTarget,
            eaten: totalCalories,
            remaining: profile.dailyCalorieTarget - totalCalories
        )
        calorieProgressViewModel.updateProgress(calorieProgress)
        
        let macros = [
            MacroProgress(title: "Protein", current: totalProtein, target: profile.proteinTarget, unit: "g", color: .green),
            MacroProgress(title: "Carbs", current: totalCarbs, target: profile.carbTarget, unit: "g", color: .customOrange),
            MacroProgress(title: "Fats", current: totalFats, target: profile.fatTarget, unit: "g", color: .yellow),
            MacroProgress(title: "Fiber", current: totalFiber, target: profile.fiberTarget, unit: "g", color: .blue),
        ]
        macroProgressViewModel.updateMacros(macros)
    }
    
    func refreshSteps(using healthKitManager: HealthKitManager, force: Bool = false) {
        
           guard force || stepsToday == 0 else { return }
           guard !isFetchingSteps else {
               print("ProgressViewModel: fetch already in progress — skipping")
               return
           }

           isFetchingSteps = true
           print("ProgressViewModel: refreshing steps")

           healthKitManager.fetchTodayStepsWithCaching { [weak self] steps in
               guard let self = self else { return }
               Task { @MainActor in
                   self.stepsToday = Int(steps)
                   self.isFetchingSteps = false
               }
           }
       }
   }

