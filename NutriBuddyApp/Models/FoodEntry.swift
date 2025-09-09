//
//  FoodEntry.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//
//
import SwiftUI
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var sugarPer100g: Double
    var grams: Double
    var date: Date
    var inputMode: String 
    var servingSize: Double?
    
    init(
        name: String,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        carbsPer100g: Double = 0,
        fatPer100g: Double = 0,
        fiberPer100g: Double = 0,
        sugarPer100g: Double = 0,
        grams: Double,
        date: Date = Date(),
        inputMode: String = "grams",
        servingSize: Double? = nil
    ) {
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.sugarPer100g = sugarPer100g
        self.grams = grams
        self.date = date
        self.inputMode = inputMode
        self.servingSize = servingSize
    }

    // MARK: - Computed totals (unchanged for backward compatibility)
    var totalCalories: Double {
        (caloriesPer100g * grams) / 100
    }

    var totalProtein: Double {
        (proteinPer100g * grams) / 100
    }

    var totalCarbs: Double {
        (carbsPer100g * grams) / 100
    }

    var totalFat: Double {
        (fatPer100g * grams) / 100
    }

    var totalFiber: Double {
        (fiberPer100g * grams) / 100
    }

    var totalSugar: Double {
        (sugarPer100g * grams) / 100
    }
    
    // MARK: - Helper computed properties
    var isServingMode: Bool {
        inputMode == "servings"
    }
    
    var displayWeight: String {
        if isServingMode && servingSize != nil {
            let servingCount = grams / servingSize!
            if abs(servingCount - 1.0) < 0.01 {
                return "1 serving"
            } else {
                return "\(servingCount.formatted(.number.precision(.fractionLength(0...2)))) servings"
            }
        } else {
            return "\(grams.formatted(.number.precision(.fractionLength(0...1))))g"
        }
    }
    
    var servingsCount: Double {
        guard isServingMode, let servingSize = servingSize else { return 1 }
        return grams / servingSize
    }
}
