//
//  ProfileViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//

import SwiftUI
import SwiftData

@MainActor
class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var age: String = ""
    @Published var weight: String = ""
    @Published var height: String = ""
    @Published var selectedGender: Gender = .male
    @Published var selectedActivity: ActivityLevel = .moderate
    @Published var selectedGoal: WeightGoal = .maintain
    
    @Published var showingSuccessAlert = false
    @Published var isUpdating = false
    @Published var stepsToday: Double = 0
    
    // MARK: - Private Properties
    private var modelContext: ModelContext?
    private var profiles: [UserProfile] = []
    
    // MARK: - Computed Properties
    var previewProfile: UserProfile? {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height),
              ageInt > 0, weightDouble > 0, heightInt > 0 else {
            return nil
        }
        
        return UserProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightInt,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
    }
    
    var isProfileValid: Bool {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else {
            return false
        }
        
        return ageInt > 0 && ageInt < 120 &&
        weightDouble > 0 && weightDouble < 500 &&
        heightInt > 0 && heightInt < 300
    }
    
    // MARK: - Initialization
    func configure(context: ModelContext, profiles: [UserProfile]) {
        self.modelContext = context
        self.profiles = profiles
        loadProfile()
    }
    
    // MARK: - Profile Management
    func loadProfile() {
        guard let profile = profiles.first else { return }
        age = "\(profile.age)"
        weight = "\(profile.weight)"
        height = "\(profile.height)"
        selectedGender = profile.gender
        selectedActivity = profile.activityLevel
        selectedGoal = profile.goal
    }
    
    func updateProfileIfValid() {
        guard isProfileValid,
              let profile = profiles.first,
              let context = modelContext else { return }
        
        profile.gender = selectedGender
        profile.activityLevel = selectedActivity
        profile.goal = selectedGoal
        
        try? context.save()
    }
    
    func saveProfile() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height),
              let profile = profiles.first,
              let context = modelContext else { return }
        
        isUpdating = true
        
        
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            
            profile.age = ageInt
            profile.weight = weightDouble
            profile.height = heightInt
            profile.gender = selectedGender
            profile.activityLevel = selectedActivity
            profile.goal = selectedGoal
            
            do {
                try context.save()
                showingSuccessAlert = true
            } catch {
                print("Error saving profile: \(error)")
                
            }
            
            isUpdating = false
        }
    }
    
    // MARK: - Field Change Handlers
    func onGenderChanged() {
        updateProfileIfValid()
    }
    
    func onActivityLevelChanged() {
        updateProfileIfValid()
    }
    
    func onGoalChanged() {
        updateProfileIfValid()
    }
    
    func dismissSuccessAlert() {
        showingSuccessAlert = false
    }
    
    func fetchSteps(from healthManager: HealthKitManager) {
          print("ProfileViewModel: fetchSteps called")
          healthManager.fetchTodaySteps { [weak self] steps in
              print("ProfileViewModel: received steps: \(steps)")
              DispatchQueue.main.async {
                  self?.stepsToday = steps
                  print("ProfileViewModel: stepsToday updated to: \(self?.stepsToday ?? 0)")
              }
          }
      }
      
}
