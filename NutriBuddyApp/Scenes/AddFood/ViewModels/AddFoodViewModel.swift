//
//  AddFoodViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//

import SwiftUI
import SwiftData

final class AddFoodViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var caloriesPer100g = ""
    @Published var proteinPer100g = ""
    @Published var carbsPer100g = ""
    @Published var fatPer100g = ""
    @Published var grams = ""
    @Published var showAdvancedOptions = false
    @Published var fiberPer100g = ""
    @Published var sugarPer100g = ""

    let selectedDate: Date
    
    // MARK: - Private Dependencies
    private var context: ModelContext
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self.context = context
    }
    
    // MARK: - Computed Properties for View
    var isValidForm: Bool {
        !name.isEmpty &&
        Double(caloriesPer100g) != nil &&
        Double(proteinPer100g) != nil &&
        Double(grams) != nil
    }
    

    var calculatedCalories: Double {
        guard let cal = Double(caloriesPer100g), cal > 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (cal * gr) / 100
    }
    
    var calculatedProtein: Double {
        guard let prot = Double(proteinPer100g), prot >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (prot * gr) / 100
    }
    
    var calculatedCarbs: Double {
        guard let carbs = Double(carbsPer100g), carbs >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (carbs * gr) / 100
    }
    
    var calculatedFat: Double {
        guard let fat = Double(fatPer100g), fat >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (fat * gr) / 100
    }
    
    var calculatedFiber: Double {
        guard let fiber = Double(fiberPer100g), fiber >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (fiber * gr) / 100
    }
    
    var calculatedSugar: Double {
        guard let sugar = Double(sugarPer100g), sugar >= 0,
              let gr = Double(grams), gr > 0 else { return 0 }
        return (sugar * gr) / 100
    }

    // MARK: - Actions
    func saveFood() {
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
    }
}
