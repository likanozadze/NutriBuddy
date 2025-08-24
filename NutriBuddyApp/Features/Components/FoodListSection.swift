//
//  FoodListSection.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct FoodListSection: View {
    let foods: [FoodEntry]
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(foods) { food in
                FoodRowView(food: food)
            }
            .onDelete(perform: onDelete)
        }
    }
}
