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
    
    var selectedDate: Date

    var body: some View {
        Form {
            TextField("Food name", text: $name)
            TextField("Calories per 100g", text: $caloriesPer100g)
                .keyboardType(.decimalPad)
            TextField("Protein per 100g", text: $proteinPer100g)
                .keyboardType(.decimalPad)
            TextField("Grams eaten", text: $grams)
                .keyboardType(.decimalPad)

            Button("Save") {
                let food = FoodEntry(
                    name: name,
                    caloriesPer100g: Double(caloriesPer100g) ?? 0,
                    proteinPer100g: Double(proteinPer100g) ?? 0,
                    grams: Double(grams) ?? 0,
                    date: selectedDate
                )
                context.insert(food)
                try? context.save()
                dismiss()
            }
        }
        .navigationTitle("Add Food")
    }
}
