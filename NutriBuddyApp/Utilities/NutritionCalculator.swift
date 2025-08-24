//
//  NutritionCalculator.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI


final class NutritionCalculator {
    static func calculateTotalCalories(from foods: [FoodEntry]) -> Double {
        foods.reduce(0) { $0 + $1.totalCalories }
    }
    
    static func calculateTotalProtein(from foods: [FoodEntry]) -> Double {
        foods.reduce(0) { $0 + $1.totalProtein }
    }
    
    static func filterFoodsForDate(_ foods: [FoodEntry], date: Date) -> [FoodEntry] {
        foods.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    
    }
}
