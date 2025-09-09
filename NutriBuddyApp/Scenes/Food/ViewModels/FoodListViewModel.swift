//
//  FoodListViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - FoodListViewModel
@Observable
class FoodListViewModel {
    var selectedDate = Date()
    
    private var allFoods: [FoodEntry] = []
    private var profiles: [UserProfile] = []
    private var context: ModelContext?
    
    // MARK: - Computed Properties
    var dailyFoods: [FoodEntry] {
        NutritionCalculator.filterFoodsForDate(allFoods, date: selectedDate)
    }
    
    var totalCalories: Double {
        NutritionCalculator.calculateTotalCalories(from: dailyFoods)
    }
    
    var totalProtein: Double {
        NutritionCalculator.calculateTotalProtein(from: dailyFoods)
    }
    
    var currentProfile: UserProfile? {
        profiles.first
    }
    
    var caloriesRemaining: Double {
        guard let profile = currentProfile else { return 0 }
        return profile.dailyCalorieTarget - totalCalories
    }
    
    var formattedDate: String {
        DateFormatter.dateLabel(for: selectedDate)
    }
    
    // MARK: - Setup
    func updateFoods(_ foods: [FoodEntry], context: ModelContext) {
        self.allFoods = foods
        self.context = context
    }
    
    func updateProfiles(_ profiles: [UserProfile]) {
        self.profiles = profiles
    }
    
    // MARK: - Actions
    func navigateDate(by days: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
    }
    
    func deleteFood(_ food: FoodEntry) {
        guard let context = context else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            context.delete(food)
            do {
                try context.save()
            } catch {
                print("Failed to delete food: \(error)")
            }
        }
    }
}
