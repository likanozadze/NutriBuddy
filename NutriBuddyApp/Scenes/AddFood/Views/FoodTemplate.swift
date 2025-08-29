//
//  FoodTemplate.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.
//

import Foundation

// MARK: - Food Template Model
struct FoodTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let inputMode: String
    let servingSize: Double?
    let timesUsed: Int
    let lastUsed: Date
    
    var isServingMode: Bool {
        inputMode == "servings"
    }
}
