//
//  FoodRowView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
struct FoodRowView: View {
    let food: FoodEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(food.name)
                .font(.headline)
            Text("\(food.grams.asGramString) → \(food.totalCalories.asCalorieString), \(food.totalProtein.asProteinString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
