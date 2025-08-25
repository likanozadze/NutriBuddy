//
//  ProgressViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

@MainActor
class ProgressViewModel: ObservableObject {
    @Published var calorieProgressViewModel = CalorieProgressViewModel()
    @Published var macroProgressViewModel = MacroProgressViewModel()
    @Published private(set) var hasProfile = false
    
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
        
       
        let calorieProgress = CalorieProgress(
            target: profile.dailyCalorieTarget,
            eaten: totalCalories,
            remaining: profile.dailyCalorieTarget - totalCalories
        )
        calorieProgressViewModel.updateProgress(calorieProgress)
        
       
        let macros = createMacroProgress(
            totalProtein: totalProtein,
            totalCarbs: 0, // You can add carbs calculation to NutritionCalculator
            profile: profile
        )
        macroProgressViewModel.updateMacros(macros)
    }
    
    private func createMacroProgress(totalProtein: Double, totalCarbs: Double, profile: UserProfile) -> [MacroProgress] {
        return [
            MacroProgress(
                title: "Protein",
                current: totalProtein,
                target: profile.proteinTarget,
                unit: "g",
                color: .green
            ),
            MacroProgress(
                title: "Carbs",
                current: totalCarbs,
                target: profile.carbTarget,
                unit: "g",
                color: .customOrange
            )
        ]
    }
}
