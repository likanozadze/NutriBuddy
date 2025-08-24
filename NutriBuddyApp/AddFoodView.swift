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
    @State private var grams = ""
    
    let selectedDate: Date
    
    private var isValidForm: Bool {
        !name.isEmpty &&
        Double(caloriesPer100g) != nil &&
        Double(proteinPer100g) != nil &&
        Double(grams) != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                foodDetailsSection
                calculatedValuesSection
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") { saveFood() }
                        .disabled(!isValidForm)
                }
            }
        }
    }
    private var foodDetailsSection: some View {
        Section("Food Details") {
            TextField("Food name", text: $name)
            TextField("Calories per 100g", text: $caloriesPer100g) .keyboardType(.decimalPad)
            TextField("Protein per 100g", text: $proteinPer100g) .keyboardType(.decimalPad)
            TextField("Amount in grams", text: $grams) .keyboardType(.decimalPad)
        }
    }
    private var calculatedValuesSection: some View {
        Section("Preview") {
            HStack { Text("Total Calories:")
                Spacer()
                Text(calculatedCalories.asCalorieString)
                .fontWeight(.semibold) }
            HStack { Text("Total Protein:")
                Spacer()
                Text(calculatedProtein.asProteinString)
                    .fontWeight(.semibold)
            }
        }
    }
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
    
    private func saveFood() {
        guard let calories = Double(caloriesPer100g),
              let protein = Double(proteinPer100g),
              let weight = Double(grams) else { return }
        let food = FoodEntry(
            name: name,
            caloriesPer100g: calories,
            proteinPer100g: protein,
            grams: weight,
            date: selectedDate
        )
        context.insert(food)
        dismiss()
    }
}
