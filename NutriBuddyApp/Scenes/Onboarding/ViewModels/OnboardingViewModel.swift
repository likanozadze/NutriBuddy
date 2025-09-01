//
//  OnboardingViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Protocols (Dependency Inversion Principle)

protocol ValidationService {
    func validateAge(_ age: String) -> Bool
    func validateWeight(_ weight: String) -> Bool
    func validateHeight(_ height: String) -> Bool
}

protocol CalorieCalculationService {
    func calculateDailyCalories(for profile: UserProfileData) -> Int?
}

protocol ProfilePersistenceService {
    func saveProfile(_ profile: UserProfileData, context: ModelContext) throws
}

protocol OnboardingNavigationService {
    func canProceedFromStep(_ step: Int, with data: OnboardingData) -> Bool
    func nextStep(from currentStep: Int) -> Int
    func previousStep(from currentStep: Int) -> Int
}

// MARK: - Data Models

struct OnboardingData {
    var age: String = ""
    var weight: String = ""
    var height: String = ""
    var selectedGender: Gender = .female
    var selectedActivity: ActivityLevel = .moderate
    var selectedGoal: WeightGoal = .maintain
}

struct UserProfileData {
    let age: Int
    let weight: Double
    let height: Int
    let gender: Gender
    let activityLevel: ActivityLevel
    let goal: WeightGoal
}

// MARK: - Service Implementations

class DefaultValidationService: ValidationService {
    private let ageRange = 13...120
    private let weightRange = 30.0...500.0
    private let heightRange = 100...250
    
    func validateAge(_ age: String) -> Bool {
        guard let ageInt = Int(age) else { return false }
        return ageRange.contains(ageInt)
    }
    
    func validateWeight(_ weight: String) -> Bool {
        guard let weightDouble = Double(weight) else { return false }
        return weightRange.contains(weightDouble)
    }
    
    func validateHeight(_ height: String) -> Bool {
        guard let heightInt = Int(height) else { return false }
        return heightRange.contains(heightInt)
    }
}

class DefaultCalorieCalculationService: CalorieCalculationService {
    func calculateDailyCalories(for profile: UserProfileData) -> Int? {
        let userProfile = UserProfile(
            age: profile.age,
            weight: profile.weight,
            height: profile.height,
            gender: profile.gender,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )
        return Int(userProfile.dailyCalorieTarget)
    }
}

class DefaultProfilePersistenceService: ProfilePersistenceService {
    func saveProfile(_ profile: UserProfileData, context: ModelContext) throws {
        let userProfile = UserProfile(
            age: profile.age,
            weight: profile.weight,
            height: profile.height,
            gender: profile.gender,
            activityLevel: profile.activityLevel,
            goal: profile.goal
        )
        
        context.insert(userProfile)
        try context.save()
    }
}

class DefaultOnboardingNavigationService: OnboardingNavigationService {
    private let validationService: ValidationService
    
    init(validationService: ValidationService) {
        self.validationService = validationService
    }
    
    func canProceedFromStep(_ step: Int, with data: OnboardingData) -> Bool {
        switch step {
        case 0: return true
        case 1: return validationService.validateAge(data.age)
        case 2: return validationService.validateWeight(data.weight)
        case 3: return validationService.validateHeight(data.height)
        case 4, 5, 6: return true
        default: return false
        }
    }
    
    func nextStep(from currentStep: Int) -> Int {
        return min(currentStep + 1, 6)
    }
    
    func previousStep(from currentStep: Int) -> Int {
        return max(currentStep - 1, 0)
    }
}

// MARK: - ViewModel

@MainActor
class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentStep = 0
    @Published var onboardingData = OnboardingData()
    @Published var calculatedCalories: Int?
    @Published var errorMessage: String?
    
    // MARK: - Services (Dependency Injection)
    private let validationService: ValidationService
    private let calorieCalculationService: CalorieCalculationService
    private let persistenceService: ProfilePersistenceService
    private let navigationService: OnboardingNavigationService
    
    // MARK: - Computed Properties
    var canProceed: Bool {
        navigationService.canProceedFromStep(currentStep, with: onboardingData)
    }
    
    var isLastStep: Bool {
        currentStep == 6
    }
    
    var stepTitle: String {
        switch currentStep {
        case 0: return "Welcome"
        case 1...5: return "About you"
        default: return "Complete"
        }
    }
    
    // MARK: - Initialization
    init(
        validationService: ValidationService = DefaultValidationService(),
        calorieCalculationService: CalorieCalculationService = DefaultCalorieCalculationService(),
        persistenceService: ProfilePersistenceService = DefaultProfilePersistenceService(),
        navigationService: OnboardingNavigationService? = nil
    ) {
        self.validationService = validationService
        self.calorieCalculationService = calorieCalculationService
        self.persistenceService = persistenceService
        self.navigationService = navigationService ?? DefaultOnboardingNavigationService(
            validationService: validationService
        )
    }
    
    // MARK: - Public Methods
    func nextStep() {
        let newStep = navigationService.nextStep(from: currentStep)
        currentStep = newStep
        
        if isLastStep {
            updateCalculatedCalories()
        }
    }
    
    func previousStep() {
        currentStep = navigationService.previousStep(from: currentStep)
    }
    
    func saveProfile(context: ModelContext, onComplete: @escaping () -> Void) {
        guard let profileData = createUserProfileData() else {
            errorMessage = "Invalid profile data"
            return
        }
        
        do {
            try persistenceService.saveProfile(profileData, context: context)
            onComplete()
        } catch {
            errorMessage = "Failed to save profile: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Private Methods
    private func createUserProfileData() -> UserProfileData? {
        guard let age = Int(onboardingData.age),
              let weight = Double(onboardingData.weight),
              let height = Int(onboardingData.height) else {
            return nil
        }
        
        return UserProfileData(
            age: age,
            weight: weight,
            height: height,
            gender: onboardingData.selectedGender,
            activityLevel: onboardingData.selectedActivity,
            goal: onboardingData.selectedGoal
        )
    }
    
    private func updateCalculatedCalories() {
        guard let profileData = createUserProfileData() else {
            calculatedCalories = nil
            return
        }
        
        calculatedCalories = calorieCalculationService.calculateDailyCalories(for: profileData)
    }
}

