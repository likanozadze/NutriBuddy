//
//  OnboardingViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//

import Foundation
import SwiftData

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var age = ""
    @Published var weight = ""
    @Published var height = ""
    @Published var selectedGender = Gender.male
    @Published var selectedActivity = ActivityLevel.moderate
    @Published var selectedGoal = WeightGoal.maintain
    

    var isValidAge: Bool {
        guard let ageInt = Int(age) else { return false }
        return ageInt >= 13 && ageInt <= 120
    }
    
    var isValidWeight: Bool {
        guard let weightDouble = Double(weight) else { return false }
        return weightDouble >= 30 && weightDouble <= 500
    }
    
    var isValidHeight: Bool {
        guard let heightInt = Int(height) else { return false }
        return heightInt >= 100 && heightInt <= 250
    }
    
    var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return isValidAge
        case 2: return isValidWeight
        case 3: return isValidHeight
        case 4, 5, 6: return true
        default: return false
        }
    }
    

    func calculateDailyCalories() -> Int? {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else { return nil }
        
        let tempProfile = UserProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightInt,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
        
        return Int(tempProfile.dailyCalorieTarget)
    }
    
    func saveProfile(context: ModelContext, onComplete: () -> Void) {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else {
            print("Invalid profile data")
            return
        }
        
        let profile = UserProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightInt,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
        
        do {
            context.insert(profile)
            try context.save()
            onComplete()
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
    

    func nextStep() {
        currentStep += 1
    }
    
    func previousStep() {
        currentStep -= 1
    }
}
