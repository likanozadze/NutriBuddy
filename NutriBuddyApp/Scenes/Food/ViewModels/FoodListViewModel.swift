//
//  FoodListViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData
import Foundation

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
    func setup(allFoods: [FoodEntry], profiles: [UserProfile], context: ModelContext) {
        self.allFoods = allFoods
        self.profiles = profiles
        self.context = context
    }
    
    // MARK: - Actions
    func navigateDate(by days: Int) {
        selectedDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) ?? selectedDate
    }
    
    func deleteFoods(at offsets: IndexSet) {
        guard let context = context else { return }
        
        offsets.forEach { index in
            context.delete(dailyFoods[index])
        }
        try? context.save()
    }
}
