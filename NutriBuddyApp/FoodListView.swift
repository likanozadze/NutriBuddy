//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query var foods: [FoodEntry]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(foods) { food in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name).font(.headline)
                        Text("\(Int(food.grams)) g → \(Int(food.totalCalories)) kcal, \(food.totalProtein, specifier: "%.1f") g protein")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
            .navigationTitle("Today's Foods")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add") {
                        AddFoodView()
                    }
                }
            }
        }
    }
}
