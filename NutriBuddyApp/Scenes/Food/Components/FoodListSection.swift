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
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.orange)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(.orange.opacity(0.1)))
                    
                    Text("Food log")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("\(foods.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            
            if foods.isEmpty {
                EmptyFoodLogView()
                    .padding(.vertical, 32)
            } else {
                List {
                    ForEach(foods, id: \.id) { food in
                        HStack {
                            FoodRowView(food: food)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .onDelete(perform: onDelete)

                }
                .listStyle(.plain)
                .frame(height: 300)
            }
        }
        .background(Color(.systemGroupedBackground).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct EmptyFoodLogView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "plus.circle")
                .font(.system(size: 48))
                .foregroundColor(.orange.opacity(0.6))
            
            VStack(spacing: 4) {
                Text("No food logged yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tap 'Add Food' to start tracking")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

