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
    @StateObject private var viewModel = OnboardingViewModel()
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                switch viewModel.currentStep {
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
                    if viewModel.currentStep > 0 {
                        Button("Back") {
                            viewModel.previousStep()
                        }
                        .buttonStyle(.bordered)
                        .tint(.customBlue)
                    }
                    
                    Spacer()
                    
                    Button(viewModel.currentStep == 6 ? "Complete Setup" : "Next") {
                        if viewModel.currentStep == 6 {
                            viewModel.saveProfile(context: context, onComplete: onComplete)
                        } else {
                            viewModel.nextStep()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.customBlue)
                    .disabled(!viewModel.canProceed)
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
                .foregroundColor(.customBlue)
            
            Text("Welcome to NutriBuddy!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text("Let's set up your profile to calculate your personalized daily calorie goal")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondaryText)
            
            Text("This will only take a minute")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
        }
        .padding()

    }
    
    private var ageStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.customBlue)
            
            Text("What's your age?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            TextField("Enter your age", text: $viewModel.age)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .multilineTextAlignment(.center)
            
            Text("We use this to calculate your metabolic rate")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .padding()
      
    }
    
    private var weightStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "scalemass")
                .font(.system(size: 60))
                .foregroundColor(.customBlue)
            
            Text("What's your current weight?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            HStack {
                TextField("Weight", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text("kg")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
            }
            
            Text("Don't worry, you can update this anytime")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .padding()
    
    }
    
    private var heightStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "ruler")
                .font(.system(size: 60))
                .foregroundColor(.customBlue)
            
            Text("What's your height?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            HStack {
                TextField("Height", text: $viewModel.height)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                
                Text("cm")
                    .font(.title3)
                    .foregroundColor(.secondaryText)
            }
            
            Text("Used for accurate calorie calculation")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .padding()
      
    }
    
    private var genderActivityStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(.customBlue)
            
            Text("Tell us about yourself")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Gender")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Picker("Gender", selection: $viewModel.selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
                .background(Color.cardBackground)
                
                Text("Activity Level")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Picker("Activity Level", selection: $viewModel.selectedActivity) {
                    ForEach(ActivityLevel.allCases, id: \.self) { activity in
                        Text(activity.rawValue).tag(activity)
                            .foregroundColor(.primaryText)
                    }
                }
                .pickerStyle(.wheel)
                .background(Color.cardBackground)
            }
        }
        .padding()
    }
    
    private var goalStep: some View {
        VStack(spacing: 30) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.customBlue)
            
            Text("What's your goal?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(WeightGoal.allCases, id: \.self) { goal in
                    Button(action: {
                        viewModel.selectedGoal = goal
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedGoal == goal ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedGoal == goal ? .customBlue : .secondaryText)
                            
                            Text(goal.rawValue)
                                .foregroundColor(.primaryText)
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedGoal == goal ? Color.customBlue.opacity(0.1) : Color.cardBackground)
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
            completionHeader
            calorieGoalCard
            completionFooter
        }
        .padding()
    }
    
    private var completionHeader: some View {
        VStack(spacing: 15) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.customGreen)
            
            Text("All Set!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
        }
    }
    
    private var calorieGoalCard: some View {
        Group {
            if let calculatedCalories = viewModel.calculateDailyCalories() {
                VStack(spacing: 10) {
                    Text("Your daily calorie goal:")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text("\(calculatedCalories) kcal")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.customBlue)
                    
                    Text("Based on your profile and \(viewModel.selectedGoal.rawValue.lowercased())")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.customBlue.opacity(0.1))
                )
            }
        }
    }
    
    private var completionFooter: some View {
        Text("You can always update your profile later")
            .font(.caption)
            .foregroundColor(.secondaryText)
    }
}
