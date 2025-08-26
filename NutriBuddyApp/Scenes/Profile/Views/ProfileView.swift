//
//  ProfileView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//
//import SwiftUI
//import SwiftData
//
//struct ProfileView: View {
//    @Query var profiles: [UserProfile] 
//    @Environment(\.modelContext) private var context
//    
//    @State private var age: String = ""
//    @State private var weight: String = ""
//    @State private var height: String = ""
//    @State private var selectedGender: Gender = .male
//    @State private var selectedActivity: ActivityLevel = .moderate
//    @State private var selectedGoal: WeightGoal = .maintain
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Personal Info") {
//                    TextField("Age", text: $age).keyboardType(.numberPad)
//                    TextField("Weight (kg)", text: $weight).keyboardType(.decimalPad)
//                    TextField("Height (cm)", text: $height).keyboardType(.numberPad)
//                    Picker("Gender", selection: $selectedGender) {
//                        ForEach(Gender.allCases, id: \.self) { Text($0.rawValue) }
//                    }
//                }
//                
//                Section("Activity & Goal") {
//                    Picker("Activity Level", selection: $selectedActivity) {
//                        ForEach(ActivityLevel.allCases, id: \.self) { Text($0.rawValue) }
//                    }
//                    Picker("Weight Goal", selection: $selectedGoal) {
//                        ForEach(WeightGoal.allCases, id: \.self) { Text($0.rawValue) }
//                    }
//                }
//                
//                Section("Calorie Info") {
//                    if let profile = profiles.first {
//                        Text("Daily Calorie Target: \(Int(profile.dailyCalorieTarget)) kcal")
//                    }
//                }
//                
//                Button("Update Profile") {
//                    saveProfile()
//                }
//                .buttonStyle(.borderedProminent)
//            }
//            .navigationTitle("Profile")
//            .onAppear(perform: loadProfile)
//        }
//    }
//    
//    private func loadProfile() {
//        guard let profile = profiles.first else { return }
//        age = "\(profile.age)"
//        weight = "\(profile.weight)"
//        height = "\(profile.height)"
//        selectedGender = profile.gender
//        selectedActivity = profile.activityLevel
//        selectedGoal = profile.goal
//    }
//    
//    private func saveProfile() {
//        guard let ageInt = Int(age),
//              let weightDouble = Double(weight),
//              let heightInt = Int(height),
//              let profile = profiles.first else { return }
//        
//        profile.age = ageInt
//        profile.weight = weightDouble
//        profile.height = heightInt
//        profile.gender = selectedGender
//        profile.activityLevel = selectedActivity
//        profile.goal = selectedGoal
//        
//        try? context.save()
//    }
//}
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
    
    @State private var showingSuccessAlert = false
    @State private var isUpdating = false
    
    // Real-time calculated profile for preview
    private var previewProfile: UserProfile? {
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with gradient
                    headerSection
                    
                    // Personal Info Card
                    personalInfoCard
                    
                    // Activity & Goal Card
                    activityGoalCard
                    
                    // Real-time Calorie & Macro Display
                    nutritionDisplayCard
                    
                    // Update Button
                    updateButton
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color.appBackground)
         //   .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onAppear(perform: loadProfile)
            .alert("Profile Updated!", isPresented: $showingSuccessAlert) {
                Button("OK") { }
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
                CustomInputField(
                    title: "Age",
                    value: $age,
                    placeholder: "Enter your age",
                    icon: "calendar",
                    keyboardType: .numberPad
                )
                
                CustomInputField(
                    title: "Weight (kg)",
                    value: $weight,
                    placeholder: "Enter your weight",
                    icon: "scalemass",
                    keyboardType: .decimalPad
                )
                
                CustomInputField(
                    title: "Height (cm)",
                    value: $height,
                    placeholder: "Enter your height",
                    icon: "ruler",
                    keyboardType: .numberPad
                )
                
                // Gender Picker
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.customGreen)
                            .font(.system(size: 16))
                        Text("Gender")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue)
                                .tag(gender)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedGender) { _, _ in
                        updateProfileIfValid()
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
                // Activity Level
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
                        Picker("Activity Level", selection: $selectedActivity) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Text(level.rawValue)
                                    .tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .onChange(of: selectedActivity) { _, _ in
                        updateProfileIfValid()
                    }
                }
                
                // Weight Goal
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
                        Picker("Weight Goal", selection: $selectedGoal) {
                            ForEach(WeightGoal.allCases, id: \.self) { goal in
                                Text(goal.rawValue)
                                    .tag(goal)
                            }
                        }
                        .pickerStyle(.menu)
                        Spacer()
                    }
                    .onChange(of: selectedGoal) { _, _ in
                        updateProfileIfValid()
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
            // Header
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Daily Nutrition Targets")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let preview = previewProfile {
                VStack(spacing: 20) {
                    // Main Calorie Display
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
                    
                    // BMR Display
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
                    
                    // Macro Targets
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
        Button(action: saveProfile) {
            HStack {
                if isUpdating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                }
                
                Text(isUpdating ? "Updating..." : "Save Profile")
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
            .disabled(isUpdating || !isProfileValid)
            .opacity(isProfileValid ? 1.0 : 0.6)
        }
        .animation(.easeInOut(duration: 0.2), value: isUpdating)
    }
    
    // MARK: - Helper Properties
    private var isProfileValid: Bool {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height) else {
            return false
        }
        
        return ageInt > 0 && ageInt < 120 &&
               weightDouble > 0 && weightDouble < 500 &&
               heightInt > 0 && heightInt < 300
    }
    
    // MARK: - Methods
    private func loadProfile() {
        guard let profile = profiles.first else { return }
        age = "\(profile.age)"
        weight = "\(profile.weight)"
        height = "\(profile.height)"
        selectedGender = profile.gender
        selectedActivity = profile.activityLevel
        selectedGoal = profile.goal
    }
    
    private func updateProfileIfValid() {
        // Auto-update profile when selections change (real-time)
        guard isProfileValid, let profile = profiles.first else { return }
        
        profile.gender = selectedGender
        profile.activityLevel = selectedActivity
        profile.goal = selectedGoal
        
        try? context.save()
    }
    
    private func saveProfile() {
        guard let ageInt = Int(age),
              let weightDouble = Double(weight),
              let heightInt = Int(height),
              let profile = profiles.first else { return }
        
        isUpdating = true
        
        // Simulate a brief update delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
}

// MARK: - Custom Input Field Component
struct CustomInputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let icon: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.customBlue)
                    .font(.system(size: 16))
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            TextField(placeholder, text: $value)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .font(.body)
        }
    }
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
