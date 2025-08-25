//
//  ProfileView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query var profiles: [UserProfile] 
    @Environment(\.modelContext) private var context
    
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedActivity: ActivityLevel = .moderate
    @State private var selectedGoal: WeightGoal = .maintain
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    TextField("Age", text: $age).keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $weight).keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height).keyboardType(.numberPad)
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                
                Section("Activity & Goal") {
                    Picker("Activity Level", selection: $selectedActivity) {
                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Picker("Weight Goal", selection: $selectedGoal) {
                        ForEach(WeightGoal.allCases, id: \.self) { Text($0.rawValue) }
                    }
                }
                
                Section("Calorie Info") {
                    if let profile = profiles.first {
                        Text("Daily Calorie Target: \(Int(profile.dailyCalorieTarget)) kcal")
                    }
                }
                
                Button("Save Changes") {
                    saveProfile()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Profile")
            .onAppear(perform: loadProfile)
        }
    }
    
    private func loadProfile() {
        guard let profile = profiles.first else { return }
        age = "\(profile.age)"
        weight = "\(profile.weight)"
        height = "\(profile.height)"
        selectedGender = profile.gender
        selectedActivity = profile.activityLevel
        selectedGoal = profile.goal
    }
    
    private func saveProfile() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height),
              let profile = profiles.first else { return }
        
        profile.age = ageInt
        profile.weight = weightDouble
        profile.height = heightInt
        profile.gender = selectedGender
        profile.activityLevel = selectedActivity
        profile.goal = selectedGoal
        
        try? context.save()
    }
}
