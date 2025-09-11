//
//  FoodSearchResult.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/11/25.
//

import Foundation

enum FoodSearchResult: Identifiable {
    case local(RecentFood)
    case api(APIFood)

    var id: String {
        switch self {
        case .local(let food): return "local_\(food.id)"
        case .api(let food): return "api_\(food.id)"
        }
    }

    var name: String {
        switch self {
        case .local(let food): return food.name
        case .api(let food): return food.name
        }
    }

    var caloriesPer100g: Double {
        switch self {
        case .local(let food): return food.caloriesPer100g
        case .api(let food): return food.caloriesPer100g
        }
    }

    var proteinPer100g: Double {
        switch self {
        case .local(let food): return food.proteinPer100g
        case .api(let food): return food.proteinPer100g
        }
    }
}
