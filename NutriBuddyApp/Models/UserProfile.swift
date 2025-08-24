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
}
