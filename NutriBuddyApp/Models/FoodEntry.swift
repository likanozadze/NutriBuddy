//
//  FoodEntry.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//
//import SwiftUI
//import SwiftData
//
//@Model
//final class FoodEntry {
//    var name: String
//    var caloriesPer100g: Double
//    var proteinPer100g: Double
//    var grams: Double
//    var date: Date
//
//    init(name: String, caloriesPer100g: Double, proteinPer100g: Double, grams: Double, date: Date = Date()) {
//        self.name = name
//        self.caloriesPer100g = caloriesPer100g
//        self.proteinPer100g = proteinPer100g
//        self.grams = grams
//        self.date = date
//    }
//
//    var totalCalories: Double {
//        (caloriesPer100g * grams) / 100
//    }
//
//    var totalProtein: Double {
//        (proteinPer100g * grams) / 100
//    }
//}
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

    init(
        name: String,
        caloriesPer100g: Double,
        proteinPer100g: Double,
        carbsPer100g: Double = 0,
        fatPer100g: Double = 0,
        fiberPer100g: Double = 0,
        sugarPer100g: Double = 0,
        grams: Double,
        date: Date = Date()
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
    }

    // MARK: - Computed totals
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
}

