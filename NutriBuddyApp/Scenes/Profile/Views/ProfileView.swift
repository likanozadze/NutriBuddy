//
//  ProfileView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = ProfileViewModel()
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    personalInfoCard
                    activityGoalCard
                    nutritionDisplayCard
                    updateButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .hideKeyboardOnTap()

            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.configure(context: context, profiles: profiles)
                
            }
            .alert("Profile Updated!", isPresented: $viewModel.showingSuccessAlert) {
                Button("OK") {
                    viewModel.dismissSuccessAlert()
                }
            } message: {
                Text("Your profile and nutrition targets have been successfully updated.")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.gradientStart, Color.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Your Profile")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
        }
        .padding(.top, 10)
    }
    
    // MARK: - Personal Info Card
    private var personalInfoCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "person.text.rectangle")
                    .foregroundColor(.customBlue)
                    .font(.title3)
                Text("Personal Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                CustomTextField(
                    title: "Age",
                    text: $viewModel.age,
                    icon: "calendar",
                    placeholder: "Enter your age",
                    keyboardType: .numberPad,
                    compact: true
                )

                CustomTextField(
                    title: "Weight (kg)",
                    text: $viewModel.weight,
                    icon: "scalemass",
                    placeholder: "Enter your weight",
                    keyboardType: .decimalPad,
                    compact: true
                )

                CustomTextField(
                    title: "Height (cm)",
                    text: $viewModel.height,
                    icon: "ruler",
                    placeholder: "Enter your height",
                    keyboardType: .numberPad,
                    compact: true
                )


                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.customGreen)
                            .font(.system(size: 16))
                        Text("Gender")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Picker("Gender", selection: $viewModel.selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue)
                                .tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.selectedGender) { _, _ in
                        viewModel.onGenderChanged()
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    // MARK: - Activity & Goal Card
    private var activityGoalCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Activity & Goals")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "figure.run")
                            .foregroundColor(.customBlue)
                            .font(.system(size: 16))
                        Text("Activity Level")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    HStack {
                        Picker("Activity Level", selection: $viewModel.selectedActivity) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue)
                                    .tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .onChange(of: viewModel.selectedActivity) { _, _ in
                        viewModel.onActivityLevelChanged()
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.customGreen)
                            .font(.system(size: 16))
                        Text("Weight Goal")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    HStack {
                        Picker("Weight Goal", selection: $viewModel.selectedGoal) {
                            ForEach(WeightGoal.allCases, id: \.self) { goal in
                                Text(goal.rawValue)
                                    .tag(goal)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .onChange(of: viewModel.selectedGoal) { _, _ in
                        viewModel.onGoalChanged()
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    // MARK: - Nutrition Display Card
    private var nutritionDisplayCard: some View {
        VStack(spacing: 20) {

            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Daily Nutrition Targets")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let preview = viewModel.previewProfile {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("\(Int(preview.dailyCalorieTarget))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.gradientStart, Color.gradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .animation(.easeInOut(duration: 0.3), value: preview.dailyCalorieTarget)
                        
                        Text("kcal per day")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    VStack(spacing: 4) {
                        Text("Base Metabolic Rate")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        Text("\(Int(preview.bmr)) kcal")
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    VStack(spacing: 12) {
                        Text("Macronutrient Targets")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryText)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            MacroCard(
                                title: "Protein",
                                value: Int(preview.proteinTarget),
                                unit: "g",
                                color: .customBlue,
                                icon: "figure.strengthtraining.traditional"
                            )
                            
                            MacroCard(
                                title: "Carbs",
                                value: Int(preview.carbTarget),
                                unit: "g",
                                color: .customGreen,
                                icon: "leaf.fill"
                            )
                            
                            MacroCard(
                                title: "Fat",
                                value: Int(preview.fatTarget),
                                unit: "g",
                                color: .customOrange,
                                icon: "drop.fill"
                            )
                            
                            MacroCard(
                                title: "Fiber",
                                value: Int(preview.fiberTarget),
                                unit: "g",
                                color: Color.brown,
                                icon: "heart.fill"
                            )
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text("--")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.secondaryText)
                    
                    Text("Complete your profile to see nutrition targets")
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    

    // MARK: - Update Button
    private var updateButton: some View {
        Button(action: viewModel.saveProfile) {
            HStack {
                if viewModel.isUpdating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                }
                
                Text(viewModel.isUpdating ? "Updating..." : "Save Profile")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [Color.gradientStart, Color.gradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(viewModel.isUpdating || !viewModel.isProfileValid)
            .opacity(viewModel.isProfileValid ? 1.0 : 0.6)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isUpdating)
    }
    
    // MARK: - Macro Card Component
    struct MacroCard: View {
        let title: String
        let value: Int
        let unit: String
        let color: Color
        let icon: String
        
        var body: some View {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 14))
                    Text(title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondaryText)
                    Spacer()
                }
                
                HStack {
                    Text("\(value)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Spacer()
                }
            }
            .padding(12)
            .background(Color.listBackground)
            .cornerRadius(8)
        }
    }
}
extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
