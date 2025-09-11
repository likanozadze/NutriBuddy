//
//  APIFood.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/11/25.
//

import Foundation

struct APIFood: Codable, Identifiable {
    let fdcId: Int
    let description: String
    let foodNutrients: [FoodNutrient]
    let dataType: String?
    let commonNames: String?
    let additionalDescriptions: String?

    var id: Int { fdcId }
    var formattedName: String {
            description.capitalized
        }
        
      
        var name: String {
            formattedName
        }

    var caloriesPer100g: Double { getNutrientValue(nutrientId: 1008) }
    var proteinPer100g: Double { getNutrientValue(nutrientId: 1003) }
    var carbsPer100g: Double { getNutrientValue(nutrientId: 1005) }
    var fatPer100g: Double { getNutrientValue(nutrientId: 1004) }
    var fiberPer100g: Double { getNutrientValue(nutrientId: 1079) }
    var sugarPer100g: Double { getNutrientValue(nutrientId: 2000) }

    private func getNutrientValue(nutrientId: Int) -> Double {
        foodNutrients.first { $0.nutrientId == nutrientId }?.value ?? 0
    }
}

struct FoodNutrient: Codable {
    let nutrientId: Int
    let nutrientName: String?
    let nutrientNumber: String?
    let unitName: String?
    let derivationCode: String?
    let derivationDescription: String?
    let derivationId: Int?
    let value: Double
    let foodNutrientSourceId: Int?
    let foodNutrientSourceCode: String?
    let foodNutrientSourceDescription: String?
    let rank: Int?
    let indentLevel: Int?
    let foodNutrientId: Int?
}
