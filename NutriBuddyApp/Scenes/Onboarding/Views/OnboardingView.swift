//
//  OnboardingView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData
// MARK: - Updated OnboardingView

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = OnboardingViewModel()
    
    let onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.gradientStart, .gradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    progressBar
                    
                    ScrollView {
                        VStack(spacing: 40) {
                            stepContent
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 30)
                    }
                    
                    bottomNavigation
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 0) {
            HStack {
                if viewModel.currentStep > 0 {
                    Button(action: { viewModel.previousStep() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.gradientPrimaryText)
                    }
                    .padding(.leading, 20)
                }
                
                Spacer()
                
                Text(viewModel.stepTitle)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.gradientPrimaryText)
                
                Spacer()
                
                if viewModel.currentStep > 0 {
                    Color.clear
                        .frame(width: 44, height: 44)
                        .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 16)
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= viewModel.currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 1)
        }
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentStep {
        case 0: welcomeStep
        case 1: ageStep
        case 2: weightStep
        case 3: heightStep
        case 4: genderActivityStep
        case 5: goalStep
        default: completionStep
        }
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.2))
            
            Button(action: {
                if viewModel.isLastStep {
                    viewModel.saveProfile(context: context, onComplete: onComplete)
                } else {
                    viewModel.nextStep()
                }
            }) {
                Text(viewModel.isLastStep ? "Complete Setup" : "Continue")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(viewModel.canProceed ? Color.customBlue : Color.white.opacity(0.3))
                    )
            }
            .disabled(!viewModel.canProceed)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Step Views
    
    private var welcomeStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("👋")
                    .font(.system(size: 80))
                
                Text("What would you like to achieve?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text("Let's set up your profile to calculate your personalized daily calorie goal")
                    .font(.body)
                    .foregroundColor(.gradientSecondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    private var ageStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What's your age?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText)
                    .multilineTextAlignment(.center)
                
                Text("We use this to calculate your metabolic rate")
                    .font(.body)
                    .foregroundColor(.gradientSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                TextField("", text: Binding(
                    get: { viewModel.onboardingData.age },
                    set: { viewModel.onboardingData.age = $0 }
                ))
                .keyboardType(.numberPad)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.gradientPrimaryText)
                .multilineTextAlignment(.center)
                .padding(.vertical, 20)
                .background(.white.opacity(0.15))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.onboardingData.age.isEmpty ? Color.clear : Color.white, lineWidth: 1.5)
                )
                
                Text(viewModel.onboardingData.age.isEmpty ? "Enter your age" : "years old")
                    .font(.title2)
                    .foregroundColor(.gradientSecondaryText)
            }
            
            Spacer()
        }
    }
    
    private var weightStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What's your current weight?")
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText).multilineTextAlignment(.center)
                
                Text("Don't worry, you can update this anytime")
                    .font(.body).foregroundColor(.gradientSecondaryText).multilineTextAlignment(.center)
            }
            
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: Binding(
                    get: { viewModel.onboardingData.weight },
                    set: { viewModel.onboardingData.weight = $0 }
                ))
                .keyboardType(.decimalPad)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.gradientPrimaryText)
                .multilineTextAlignment(.center)
                
                Text("kg")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.gradientSecondaryText)
                    .padding(.trailing, 12)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(.white.opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.onboardingData.weight.isEmpty ? Color.clear : Color.white, lineWidth: 1.5)
            )
            
            Spacer()
        }
    }
    
    private var heightStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What's your height?")
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText).multilineTextAlignment(.center)
                
                Text("Used for accurate calorie calculation")
                    .font(.body).foregroundColor(.gradientSecondaryText).multilineTextAlignment(.center)
            }
            
            HStack(alignment: .center, spacing: 8) {
                TextField("", text: Binding(
                    get: { viewModel.onboardingData.height },
                    set: { viewModel.onboardingData.height = $0 }
                ))
                .keyboardType(.numberPad)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.gradientPrimaryText)
                .multilineTextAlignment(.center)
                
                Text("cm")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.gradientSecondaryText)
                    .padding(.trailing, 12)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 24)
            .background(.white.opacity(0.15))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(viewModel.onboardingData.height.isEmpty ? Color.clear : Color.white, lineWidth: 1.5)
            )
            
            Spacer()
        }
    }
    
    private var genderActivityStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Tell us about yourself")
                    .font(.largeTitle).fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText).multilineTextAlignment(.center)
                
                Text("This helps us calculate your daily needs")
                    .font(.body).foregroundColor(.gradientSecondaryText).multilineTextAlignment(.center)
            }
            
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Gender")
                        .font(.title2).fontWeight(.semibold)
                        .foregroundColor(.gradientPrimaryText)
                    
                    HStack(spacing: 12) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Button(action: { viewModel.onboardingData.selectedGender = gender }) {
                                VStack(spacing: 8) {
                                    Text(gender == .male ? "👨" : "👩").font(.system(size: 32))
                                    Text(gender.rawValue)
                                        .font(.body).fontWeight(.medium)
                                        .foregroundColor(.gradientPrimaryText)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(viewModel.onboardingData.selectedGender == gender ? .white.opacity(0.25) : .white.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(viewModel.onboardingData.selectedGender == gender ? .white : .clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity Level")
                        .font(.title2).fontWeight(.semibold)
                        .foregroundColor(.gradientPrimaryText)
                    
                    VStack(spacing: 12) {
                        ForEach(ActivityLevel.allCases, id: \.self) { activity in
                            Button(action: { viewModel.onboardingData.selectedActivity = activity }) {
                                HStack(spacing: 16) {
                                    Text(activityIcon(for: activity)).font(.system(size: 24))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(activity.rawValue).font(.body).fontWeight(.medium).foregroundColor(.gradientPrimaryText)
                                        Text(activityDescription(for: activity)).font(.caption).foregroundColor(.gradientSecondaryText)
                                    }
                                    Spacer()
                                    if viewModel.onboardingData.selectedActivity == activity {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.white).font(.title3)
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(viewModel.onboardingData.selectedActivity == activity ? .white.opacity(0.25) : .white.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(viewModel.onboardingData.selectedActivity == activity ? .white : .clear, lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            Spacer()
        }
    }
    
    private var goalStep: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("What would you like to achieve?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText)
                    .multilineTextAlignment(.center)
                
                Text("Choose your primary goal")
                    .font(.body)
                    .foregroundColor(.gradientSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(WeightGoal.allCases, id: \.self) { goal in
                    Button(action: { viewModel.onboardingData.selectedGoal = goal }) {
                        HStack(spacing: 16) {
                            Text(goalIcon(for: goal))
                                .font(.system(size: 32))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(goal.rawValue)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gradientPrimaryText)
                                
                                Text(goalDescription(for: goal))
                                    .font(.caption)
                                    .foregroundColor(.gradientSecondaryText)
                            }
                            
                            Spacer()
                            
                            if viewModel.onboardingData.selectedGoal == goal {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.onboardingData.selectedGoal == goal ? .white.opacity(0.25) : .white.opacity(0.15))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(viewModel.onboardingData.selectedGoal == goal ? .white : .clear, lineWidth: 1.5)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
    }
    
    private var completionStep: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("All Set!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gradientPrimaryText)
                
                if let calculatedCalories = viewModel.calculatedCalories {
                    VStack(spacing: 16) {
                        Text("Your daily calorie goal:")
                            .font(.headline)
                            .foregroundColor(.gradientPrimaryText)
                        
                        Text("\(calculatedCalories)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        + Text(" kcal")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gradientSecondaryText)
                        
                        Text("Based on your profile and \(viewModel.onboardingData.selectedGoal.rawValue.lowercased())")
                            .font(.body)
                            .foregroundColor(.gradientSecondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.white.opacity(0.2))
                    )
                }
                
                Text("You can always update your profile later")
                    .font(.body)
                    .foregroundColor(.gradientSecondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    // MARK: - Helper Functions
    private func activityIcon(for activity: ActivityLevel) -> String {
        switch activity {
        case .sedentary: return "🪑"
        case .light: return "🚶‍♀️"
        case .moderate: return "🏃‍♀️"
        case .very: return "🏋️‍♀️"
        case .extra: return "🤸‍♀️"
        }
    }
    
    private func activityDescription(for activity: ActivityLevel) -> String {
        switch activity {
        case .sedentary: return "Little to no exercise"
        case .light: return "Light exercise 1-3 days/week"
        case .moderate: return "Moderate exercise 3-5 days/week"
        case .very: return "Heavy exercise 6-7 days/week"
        case .extra: return "Very heavy physical work"
        }
    }
    
    private func goalIcon(for goal: WeightGoal) -> String {
        switch goal {
        case .lose2, .lose1: return "🏃‍♀️"
        case .maintain: return "📏"
        case .gain1, .gain2: return "💪"
        }
    }
    
    private func goalDescription(for goal: WeightGoal) -> String {
        switch goal {
        case .lose2: return "Lose 1 kg per week"
        case .lose1: return "Lose 0.5 kg per week"
        case .maintain: return "Stay in shape"
        case .gain1: return "Gain 0.5 kg per week"
        case .gain2: return "Gain 1 kg per week"
        }
    }
}
