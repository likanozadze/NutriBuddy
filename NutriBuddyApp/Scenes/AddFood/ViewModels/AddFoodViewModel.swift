//
//  AddFoodViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/27/25.
//
//
import SwiftUI
import SwiftData

enum NutritionInputMode: String, CaseIterable {
    case grams = "grams"
    case servings = "servings"
    
    var displayName: String {
        switch self {
        case .servings: return "Servings"
        case .grams: return "Grams"
        }
    }
    
    var icon: String {
        switch self {
        case .servings: return "number.circle"
        case .grams: return "scalemass"
        }
    }
}

final class AddFoodViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var name = ""
    @Published var inputMode: NutritionInputMode = .grams 
    @Published var showAdvancedOptions = false
    
    @Published var servingAmount = ""
    @Published var servingCalories = ""
    @Published var servingProtein = ""
    @Published var servingCarbs = ""
    @Published var servingFat = ""
    @Published var servingFiber = ""
    @Published var servingSugar = ""
    
    @Published var caloriesPer100g = ""
    @Published var proteinPer100g = ""
    @Published var carbsPer100g = ""
    @Published var fatPer100g = ""
    @Published var fiberPer100g = ""
    @Published var sugarPer100g = ""
    @Published var grams = ""

    let selectedDate: Date
    
    // MARK: - Private Dependencies
    private var context: ModelContext
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self.context = context
    }
    
    // MARK: - Computed Properties for View
    var isValidForm: Bool {
        guard !name.isEmpty else { return false }
        
        switch inputMode {
        case .servings:
            return Double(servingAmount) != nil &&
                   Double(servingCalories) != nil &&
                   Double(servingProtein) != nil
        case .grams:
            return Double(caloriesPer100g) != nil &&
                   Double(proteinPer100g) != nil &&
                   Double(grams) != nil
        }
    }
    
    var calculatedCalories: Double {
        switch inputMode {
        case .servings:
            guard let cal = Double(servingCalories), cal >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return cal * amount
        case .grams:
            guard let cal = Double(caloriesPer100g), cal > 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (cal * gr) / 100
        }
    }
    
    var calculatedProtein: Double {
        switch inputMode {
        case .servings:
            guard let prot = Double(servingProtein), prot >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return prot * amount
        case .grams:
            guard let prot = Double(proteinPer100g), prot >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (prot * gr) / 100
        }
    }
    
    var calculatedCarbs: Double {
        switch inputMode {
        case .servings:
            guard let carbs = Double(servingCarbs), carbs >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return carbs * amount
        case .grams:
            guard let carbs = Double(carbsPer100g), carbs >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (carbs * gr) / 100
        }
    }
    
    var calculatedFat: Double {
        switch inputMode {
        case .servings:
            guard let fat = Double(servingFat), fat >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return fat * amount
        case .grams:
            guard let fat = Double(fatPer100g), fat >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (fat * gr) / 100
        }
    }
    
    var calculatedFiber: Double {
        switch inputMode {
        case .servings:
            guard let fiber = Double(servingFiber), fiber >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return fiber * amount
        case .grams:
            guard let fiber = Double(fiberPer100g), fiber >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (fiber * gr) / 100
        }
    }
    
    var calculatedSugar: Double {
        switch inputMode {
        case .servings:
            guard let sugar = Double(servingSugar), sugar >= 0,
                  let amount = Double(servingAmount), amount > 0 else { return 0 }
            return sugar * amount
        case .grams:
            guard let sugar = Double(sugarPer100g), sugar >= 0,
                  let gr = Double(grams), gr > 0 else { return 0 }
            return (sugar * gr) / 100
        }
    }

    // MARK: - Actions
    func saveFood() {
        switch inputMode {
        case .servings:
            guard let servCal = Double(servingCalories),
                  let servProt = Double(servingProtein),
                  let amount = Double(servingAmount) else { return }
            
            let totalGrams = amount * 100
            let calPer100g = servCal
            let protPer100g = servProt
            let carbsPer100g = Double(servingCarbs) ?? 0
            let fatPer100g = Double(servingFat) ?? 0
            let fiberPer100g = Double(servingFiber) ?? 0
            let sugarPer100g = Double(servingSugar) ?? 0
            
            let food = FoodEntry(
                name: name,
                caloriesPer100g: calPer100g,
                proteinPer100g: protPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                sugarPer100g: sugarPer100g,
                grams: totalGrams,
                date: selectedDate,
                inputMode: inputMode.rawValue,
                servingSize: 100
            )
            
            context.insert(food)
            
        case .grams:
            guard let calPer100g = Double(caloriesPer100g),
                  let protPer100g = Double(proteinPer100g),
                  let grams = Double(grams) else { return }
            
            let food = FoodEntry(
                name: name,
                caloriesPer100g: calPer100g,
                proteinPer100g: protPer100g,
                carbsPer100g: Double(carbsPer100g) ?? 0,
                fatPer100g: Double(fatPer100g) ?? 0,
                fiberPer100g: Double(fiberPer100g) ?? 0,
                sugarPer100g: Double(sugarPer100g) ?? 0,
                grams: grams,
                date: selectedDate,
                inputMode: inputMode.rawValue
            )
            
            context.insert(food)
        }

        do {
            try context.save()
        } catch {
            print("Failed to save food: \(error)")
        }
    }
}
