//
//  ProfileViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//
//
import SwiftUI
import SwiftData

// MARK: -  ProfileViewModel
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var age: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var selectedGender: Gender = .male
    @Published var selectedActivity: ActivityLevel = .sedentary
    @Published var selectedGoal: WeightGoal = .maintain
    @Published var previewProfile: UserProfile?
    @Published var showingSuccessAlert = false
    @Published var isUpdating = false
    
    private var context: ModelContext?
    private var profiles: [UserProfile] = []
    private var calculationTask: Task<Void, Never>?
    
    func configure(context: ModelContext, profiles: [UserProfile]) {
        self.context = context
        self.profiles = profiles
        loadExistingProfile()
    }
    
    func recalculateNutritionTargets() {
        calculationTask?.cancel()
        
        calculationTask = Task {
            await performNutritionCalculations()
        }
    }
    
    
    private func performNutritionCalculations() async {
        let result = await Task.detached(priority: .background) { [weak self] () -> UserProfile? in
            guard let self = self else { return nil }
            return await self.calculatePreviewProfile()
        }.value
        
        await MainActor.run {
            previewProfile = result
        }
    }

    private func calculatePreviewProfile() -> UserProfile? {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height),
              ageInt > 0,
              weightDouble > 0,
              heightInt > 0 else {
            return nil
        }
        

        let tempProfile = UserProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightInt,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
        
        return tempProfile
    }
    
    func saveProfileAsync() async {
        isUpdating = true
        
        await Task.detached { [weak self] in
            await self?.performSaveOperation()
        }.value
        
        showingSuccessAlert = true
        isUpdating = false
    }
    
    private func performSaveOperation() async {
        guard let context = context,
              let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else {
            return
        }
        
        await MainActor.run {
            do {
                
                for profile in profiles {
                    context.delete(profile)
                }
                

                let newProfile = UserProfile(
                    age: ageInt,
                    weight: weightDouble,
                    height: heightInt,
                    gender: selectedGender,
                    activityLevel: selectedActivity,
                    goal: selectedGoal
                )
                
                context.insert(newProfile)
                try context.save()
                
                previewProfile = newProfile
            } catch {
                print("Failed to save profile: \(error)")
            }
        }
    }
    
    func dismissSuccessAlert() {
        showingSuccessAlert = false
    }
    
    private func loadExistingProfile() {
        guard let existingProfile = profiles.first else { return }
        
        age = String(existingProfile.age)
        weight = String(existingProfile.weight)
        height = String(existingProfile.height)
        selectedGender = existingProfile.gender
        selectedActivity = existingProfile.activityLevel
        selectedGoal = existingProfile.goal
        previewProfile = existingProfile
    }
}
