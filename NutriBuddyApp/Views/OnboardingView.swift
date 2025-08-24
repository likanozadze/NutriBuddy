//
//  OnboardingView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var currentStep = 0
    @State private var age = ""
    @State private var weight = ""
    @State private var height = ""
    @State private var selectedGender = Gender.male
    @State private var selectedActivity = ActivityLevel.moderate
    @State private var selectedGoal = WeightGoal.maintain
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
  
                ProgressView(value: Double(currentStep), total: 6)
                    .padding()
                
         
                switch currentStep {
                case 0: welcomeStep
                case 1: ageStep
                case 2: weightStep
                case 3: heightStep
                case 4: genderActivityStep
                case 5: goalStep
                default: completionStep
                }
                
                Spacer()
                
             
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            currentStep -= 1
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button(currentStep == 6 ? "Complete Setup" : "Next") {
                        if currentStep == 6 {
                            saveProfile()
                        } else {
                            currentStep += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!canProceed)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Step Views
    
    private var welcomeStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Welcome to NutriBuddy!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Let's set up your profile to calculate your personalized daily calorie goal")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("This will only take a minute")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var ageStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("What's your age?")
                .font(.title2)
                .fontWeight(.semibold)
            
            TextField("Enter your age", text: $age)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Text("We use this to calculate your metabolic rate")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var weightStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "scalemass")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("What's your current weight?")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text("kg")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Text("Don't worry, you can update this anytime")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var heightStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "ruler")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("What's your height?")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                TextField("Height", text: $height)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text("cm")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            Text("Used for accurate calorie calculation")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var genderActivityStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Gender")
                    .font(.headline)
                
                Picker("Gender", selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
                
                Text("Activity Level")
                    .font(.headline)
                
                Picker("Activity Level", selection: $selectedActivity) {
                    ForEach(ActivityLevel.allCases, id: \.self) { activity in
                        Text(activity.rawValue).tag(activity)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
        .padding()
    }
    
    private var goalStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("What's your goal?")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(WeightGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        selectedGoal = goal
                    }) {
                        HStack {
                            Image(systemName: selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedGoal == goal ? .blue : .gray)
                            
                            Text(goal.rawValue)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedGoal == goal ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
    
    private var completionStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let ageInt = Int(age),
               let weightDouble = Double(weight),
               let heightInt = Int(height) {
                
                let tempProfile = UserProfile(
                    age: ageInt,
                    weight: weightDouble,
                    height: heightInt,
                    gender: selectedGender,
                    activityLevel: selectedActivity,
                    goal: selectedGoal
                )
                
                VStack(spacing: 10) {
                    Text("Your daily calorie goal:")
                        .font(.headline)
                    
                    Text("\(Int(tempProfile.dailyCalorieTarget)) kcal")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Based on your profile and \(selectedGoal.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            Text("You can always update your profile later")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - Helper Properties
    
    private var canProceed: Bool {
        switch currentStep {
        case 0: return true
        case 1: return !age.isEmpty && Int(age) != nil
        case 2: return !weight.isEmpty && Double(weight) != nil
        case 3: return !height.isEmpty && Int(height) != nil
        case 4: return true
        case 5: return true
        case 6: return true
        default: return false
        }
    }
    
    // MARK: - Actions
    
    private func saveProfile() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else { return }
        
        let profile = UserProfile(
            age: ageInt,
            weight: weightDouble,
            height: heightInt,
            gender: selectedGender,
            activityLevel: selectedActivity,
            goal: selectedGoal
        )
        
        context.insert(profile)
        onComplete()
    }
}

#Preview {
    
    let container = try! ModelContainer(for: UserProfile.self)

    NavigationStack {
        OnboardingView {
            print("Onboarding complete!")
        }
        .environment(\.modelContext, container.mainContext)
    }
}
