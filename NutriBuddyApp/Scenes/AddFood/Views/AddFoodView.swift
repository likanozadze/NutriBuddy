//
//  AddFoodView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var caloriesPer100g = ""
    @State private var proteinPer100g = ""
    @State private var carbsPer100g = ""
    @State private var fatPer100g = ""
    @State private var grams = ""
    @State private var showAdvancedOptions = false
    @State private var fiberPer100g = ""
    @State private var sugarPer100g = ""
    
    let selectedDate: Date
    
    private var isValidForm: Bool {
        !name.isEmpty &&
        Double(caloriesPer100g) != nil &&
        Double(proteinPer100g) != nil &&
        Double(grams) != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    inputCard
                    advancedOptionsToggle
                    if showAdvancedOptions {
                        advancedMacrosCard
                    }
                    previewCard
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.customBlue)
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(!isValidForm)
                    .foregroundColor(isValidForm ? .customBlue : .secondary)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.gradientStart, Color.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Add New Food")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text("Track your nutrition by adding food details")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
    
    private var inputCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Food Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Food Name",
                    text: $name,
                    icon: "textformat",
                    placeholder: "e.g. Chicken breast"
                )
                
                CustomTextField(
                    title: "Calories per 100g",
                    text: $caloriesPer100g,
                    icon: "flame",
                    placeholder: "e.g. 165",
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    title: "Protein per 100g",
                    text: $proteinPer100g,
                    icon: "bolt",
                    placeholder: "e.g. 31",
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    title: "Amount in grams",
                    text: $grams,
                    icon: "scalemass",
                    placeholder: "e.g. 150",
                    keyboardType: .decimalPad
                )
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var advancedOptionsToggle: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                showAdvancedOptions.toggle()
            }
        }) {
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.customBlue)
                    .rotationEffect(.degrees(showAdvancedOptions ? 90 : 0))
                    .animation(.easeInOut(duration: 0.3), value: showAdvancedOptions)
                
                Text("Advanced Macros")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("Optional")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var advancedMacrosCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(.customGreen)
                    .font(.title3)
                Text("Additional Macros")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Carbs per 100g",
                    text: $carbsPer100g,
                    icon: "leaf",
                    placeholder: "e.g. 0",
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    title: "Fat per 100g",
                    text: $fatPer100g,
                    icon: "drop",
                    placeholder: "e.g. 3.6",
                    keyboardType: .decimalPad
                )
                CustomTextField(
                    title: "Fiber per 100g",
                    text: $fiberPer100g,
                    icon: "scissors",
                    placeholder: "e.g. 2.5",
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    title: "Sugar per 100g",
                    text: $sugarPer100g,
                    icon: "cube.transparent",
                    placeholder: "e.g. 4.7",
                    keyboardType: .decimalPad
                )
            }
            
        }
        
        .padding(20)
        .cardStyle()
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.customBlue)
                    .font(.title3)
                Text("Nutrition Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MacroPreviewItem(
                        title: "Calories",
                        value: calculatedCalories.asCalorieString,
                        icon: "flame.fill",
                        color: .customOrange
                    )
                    
                    MacroPreviewItem(
                        title: "Protein",
                        value: calculatedProtein.asProteinString,
                        icon: "bolt.fill",
                        color: .customGreen
                    )
                }
                
                
                if showAdvancedOptions {
                    if calculatedCarbs > 0 || calculatedFat > 0 {
                        HStack(spacing: 20) {
                            if calculatedCarbs > 0 {
                                MacroPreviewItem(
                                    title: "Carbs",
                                    value: calculatedCarbs.asProteinString,
                                    icon: "leaf.fill",
                                    color: .customBlue
                                )
                            }
                            if calculatedFat > 0 {
                                MacroPreviewItem(
                                    title: "Fat",
                                    value: calculatedFat.asProteinString,
                                    icon: "drop.fill",
                                    color: .purple
                                )
                            }
                        }
                    }
                    
                    if calculatedFiber > 0 || calculatedSugar > 0 {
                        HStack(spacing: 20) {
                            if calculatedFiber > 0 {
                                MacroPreviewItem(
                                    title: "Fiber",
                                    value: calculatedFiber.asProteinString,
                                    icon: "scissors",
                                    color: .brown
                                )
                            }
                            if calculatedSugar > 0 {
                                MacroPreviewItem(
                                    title: "Sugar",
                                    value: calculatedSugar.asProteinString,
                                    icon: "cube.fill",
                                    color: .pink
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    
    // MARK: - Computed Properties
    private var calculatedCalories: Double {
        guard let cal = Double(caloriesPer100g), cal > 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (cal * gr) / 100
    }
    
    private var calculatedProtein: Double {
        guard let prot = Double(proteinPer100g), prot >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (prot * gr) / 100
    }
    
    private var calculatedCarbs: Double {
        guard let carbs = Double(carbsPer100g), carbs >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (carbs * gr) / 100
    }
    
    private var calculatedFat: Double {
        guard let fat = Double(fatPer100g), fat >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (fat * gr) / 100
    }
    private var calculatedFiber: Double {
        guard let fiber = Double(fiberPer100g), fiber >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (fiber * gr) / 100
    }
    
    private var calculatedSugar: Double {
        guard let sugar = Double(sugarPer100g), sugar >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (sugar * gr) / 100
    }
    
    
  
    private func saveFood() {
        guard let calories = Double(caloriesPer100g),
              let protein = Double(proteinPer100g),
              let weight = Double(grams) else { return }
        
    
        let carbs = Double(carbsPer100g) ?? 0
        let fat = Double(fatPer100g) ?? 0
        let fiber = Double(fiberPer100g) ?? 0
        let sugar = Double(sugarPer100g) ?? 0
        
        let food = FoodEntry(
            name: name,
            caloriesPer100g: calories,
            proteinPer100g: protein,
            carbsPer100g: carbs,
            fatPer100g: fat,
            fiberPer100g: fiber,
            sugarPer100g: sugar,
            grams: weight,
            date: selectedDate
        )
        
        context.insert(food)
        do {
            try context.save()
        } catch {
            print("Failed to save food: \(error)")
        }
        
        dismiss()
    }
}
struct MacroPreviewItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(8)
    }
}

