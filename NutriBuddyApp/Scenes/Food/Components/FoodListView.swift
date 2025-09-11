//
//  FoodListSection.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    let foods: [FoodEntry]
    let onDelete: (FoodEntry) -> Void
    
    var body: some View {
        List {
                ForEach(foods, id: \.id) { food in
                    FoodItemCard(food: food)
                        .listRowSeparator(.hidden)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let food = foods[index]
                        onDelete(food)
                    }
                }
            }
        
        .listStyle(.plain)
        .scrollDisabled(true)
    }
}

struct FoodItemCard: View {
    let food: FoodEntry
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                Text(amountDisplayText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 10) 
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
    }
       
    private var amountDisplayText: String {
        if food.isServingMode {
            let servingCount = food.servingsCount
            let servingText = servingCount == 1 ? "serving" : "servings"
            return "\(servingCount.clean) \(servingText) • \(food.totalCalories.asCalorieString) • \(food.totalProtein.asProteinString)"
        } else {
            return "\(food.grams.asGramString) • \(food.totalCalories.asCalorieString) • \(food.totalProtein.asProteinString)"
        }
    }
}

struct EmptyFoodLogView: View {
    let onAddFood: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: { onAddFood() }) {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.customOrange.opacity(0.6))
                    
                    VStack(spacing: 4) {
                        Text("No food logged yet")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text("Tap here to start tracking your meals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

// MARK: - Helpers
extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
