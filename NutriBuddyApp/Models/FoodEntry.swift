//
//  FoodEntry.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//
import SwiftUI
import SwiftData

@Model
final class FoodEntry {
    var name: String
    var caloriesPer100g: Double
    var proteinPer100g: Double
    var grams: Double
    var date: Date

    init(name: String, caloriesPer100g: Double, proteinPer100g: Double, grams: Double, date: Date = Date()) {
        self.name = name
        self.caloriesPer100g = caloriesPer100g
        self.proteinPer100g = proteinPer100g
        self.grams = grams
        self.date = date
    }

    var totalCalories: Double {
        (caloriesPer100g * grams) / 100
    }

    var totalProtein: Double {
        (proteinPer100g * grams) / 100
    }
}

//// MARK: - Extensions
//extension Calendar {
//    func isDate(_ date1: Date, sameDayAs date2: Date) -> Bool {
//        isDate(date1, inSameDayAs: date2)
//    }
//}

//extension Double {
//    var asCalorieString: String {
//        "\(Int(self)) kcal"
//    }
//    
//    var asProteinString: String {
//        String(format: "%.1f g", self)
//    }
//    
//    var asGramString: String {
//        "\(Int(self)) g"
//    }
//}
//
