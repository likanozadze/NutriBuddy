//
//  FoodListSection.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI
import SwiftData

struct FoodListSection: View {
    let foods: [FoodEntry]
    let selectedDate: Date
    @Environment(\.modelContext) private var context
    @State private var showingAddFood = false
    
    var body: some View {
        VStack(spacing: 16) {
           
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.customOrange)
                        .font(.title3)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.customOrange.opacity(0.1)))
                    
                    Text("Food log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                }
                Spacer()
                
                Text("\(foods.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if foods.isEmpty {
                EmptyFoodLogView(onAddFood: {
                    showingAddFood = true
                })
                .padding(.vertical, 32)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(foods, id: \.id) { food in
                        FoodItemCard(food: food, onDelete: {
                            deleteFoodItem(food)
                        })
                    }
                }
                Button(action: {
                    showingAddFood = true
                }) {
                    HStack {
                       
                        Text("Add Food")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color.appBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.customOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showingAddFood) {
            AddFoodView(selectedDate: selectedDate, context: context)
        }
    }
    
    private func deleteFoodItem(_ food: FoodEntry) {
        withAnimation(.easeInOut(duration: 0.3)) {
            context.delete(food)
            
            do {
                try context.save()
            } catch {
                print("Failed to delete food: \(error)")
            }
        }
    }
}

struct FoodItemCard: View {
    let food: FoodEntry
    let onDelete: () -> Void
    @State private var showingDeleteConfirmation = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            
            Image(systemName: "fork.knife.circle.fill")
                .font(.title2)
                .foregroundColor(.customOrange.opacity(0.8))
            
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
            
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red.opacity(0.8))
                    .frame(width: 32, height: 32)
                    .background(Color.red.opacity(colorScheme == .dark ? 0.2 : 0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .confirmationDialog("Delete Food Item", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(food.name)?")
        }
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
            Button(action: {
                onAddFood()
            }) {
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

extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
