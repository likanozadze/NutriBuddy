//
//  UserProfile.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

//import SwiftUI
//import SwiftData
//
//@Model
//final class UserProfile {
//    var age: Int
//    var weight: Double
//    var height: Int
//    var gender: Gender
//    var activityLevel: ActivityLevel
//    var goal: WeightGoal
//    var dateCreated: Date
//    
//    init(age: Int, weight: Double, height: Int, gender: Gender,
//         activityLevel: ActivityLevel, goal: WeightGoal) {
//        self.age = age
//        self.weight = weight
//        self.height = height
//        self.gender = gender
//        self.activityLevel = activityLevel
//        self.goal = goal
//        self.dateCreated = Date()
//    }
//    
//    var bmr: Double {
//        switch gender {
//        case .male:
//            return (10 * weight) + (6.25 * Double(height)) - (5 * Double(age)) + 5
//        case .female:
//            return (10 * weight) + (6.25 * Double(height)) - (5 * Double(age)) - 161
//        }
//    }
//    
//    var dailyCalorieTarget: Double {
//        let maintenanceCalories = bmr * activityLevel.multiplier
//        return maintenanceCalories + goal.calorieAdjustment
//    }
//}
//
//enum Gender: String, CaseIterable, Codable {
//    case male = "Male"
//    case female = "Female"
//}
//
//enum ActivityLevel: String, CaseIterable, Codable {
//    case sedentary = "Sedentary (little/no exercise)"
//    case light = "Lightly active (1-3 days/week)"
//    case moderate = "Moderately active (3-5 days/week)"
//    case very = "Very active (6-7 days/week)"
//    case extra = "Super active (2x/day, intense workouts)"
//    
//    var multiplier: Double {
//        switch self {
//        case .sedentary: return 1.2
//        case .light: return 1.375
//        case .moderate: return 1.55
//        case .very: return 1.725
//        case .extra: return 1.9
//        }
//    }
//}
//
//enum WeightGoal: String, CaseIterable, Codable {
//    case lose2 = "Lose 1kg per week"
//    case lose1 = "Lose 0.5kg per week"
//    case maintain = "Maintain weight"
//    case gain1 = "Gain 0.5kg per week"
//    case gain2 = "Gain 1kg per week"
//    
//    var calorieAdjustment: Double {
//        switch self {
//        case .lose2: return -1000 
//        case .lose1: return -500
//        case .maintain: return 0
//        case .gain1: return +500
//        case .gain2: return +1000
//        }
//    }
//}
//
//  UserProfile.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData

@Model
final class UserProfile {
    var age: Int
    var weight: Double
    var height: Int
    var gender: Gender
    var activityLevel: ActivityLevel
    var goal: WeightGoal
    var dateCreated: Date
    
    init(age: Int, weight: Double, height: Int, gender: Gender,
         activityLevel: ActivityLevel, goal: WeightGoal) {
        self.age = age
        self.weight = weight
        self.height = height
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.dateCreated = Date()
    }
    
    var bmr: Double {
        switch gender {
        case .male:
            return (10 * weight) + (6.25 * Double(height)) - (5 * Double(age)) + 5
        case .female:
            return (10 * weight) + (6.25 * Double(height)) - (5 * Double(age)) - 161
        }
    }
    
    var dailyCalorieTarget: Double {
        let maintenanceCalories = bmr * activityLevel.multiplier
        return maintenanceCalories + goal.calorieAdjustment
    }
    
    // MARK: - Macro Targets
    
    var proteinTarget: Double {
        let baseProtein = weight * proteinMultiplier
        return baseProtein
    }
    
    var carbTarget: Double {
        let carbCalories = dailyCalorieTarget * carbPercentage
        return carbCalories / 4.0 // 4 kcal per gram of carbs
    }
    
    var fatTarget: Double {
        let fatCalories = dailyCalorieTarget * fatPercentage
        return fatCalories / 9.0 // 9 kcal per gram of fat
    }

    var fiberTarget: Double {
        return (dailyCalorieTarget / 1000) * 14
    }
    
    // MARK: - Private Helpers
    
    private var proteinMultiplier: Double {
        switch activityLevel {
        case .sedentary:
            return goal.isWeightLoss ? 1.6 : 1.2
        case .light:
            return goal.isWeightLoss ? 1.8 : 1.4
        case .moderate:
            return goal.isWeightLoss ? 2.0 : 1.6
        case .very, .extra:
            return goal.isWeightLoss ? 2.2 : 1.8
        }
    }
    
    private var carbPercentage: Double {
        switch goal {
        case .lose2, .lose1:
            return 0.40
        case .maintain:
            return 0.50
        case .gain1, .gain2:
            return 0.55
        }
    }
    
    private var fatPercentage: Double {
        switch goal {
        case .lose2, .lose1:
            return 0.35
        case .maintain:
            return 0.30
        case .gain1, .gain2:
            return 0.25
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
}

enum ActivityLevel: String, CaseIterable, Codable {
    case sedentary = "Sedentary (little/no exercise)"
    case light = "Lightly active (1-3 days/week)"
    case moderate = "Moderately active (3-5 days/week)"
    case very = "Very active (6-7 days/week)"
    case extra = "Super active (2x/day, intense workouts)"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .very: return 1.725
        case .extra: return 1.9
        }
    }
}

enum WeightGoal: String, CaseIterable, Codable {
    case lose2 = "Lose 1kg per week"
    case lose1 = "Lose 0.5kg per week"
    case maintain = "Maintain weight"
    case gain1 = "Gain 0.5kg per week"
    case gain2 = "Gain 1kg per week"
    
    var calorieAdjustment: Double {
        switch self {
        case .lose2: return -1000
        case .lose1: return -500
        case .maintain: return 0
        case .gain1: return +500
        case .gain2: return +1000
        }
    }
    
    var isWeightLoss: Bool {
        switch self {
        case .lose2, .lose1: return true
        case .maintain, .gain1, .gain2: return false
        }
    }
}
