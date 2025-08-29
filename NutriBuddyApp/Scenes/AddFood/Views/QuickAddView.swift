//
//  QuickAddView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.
//

import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    let onFoodSelected: (RecentFood) -> Void
    @State private var searchText = ""
    
    private var filteredFoods: [RecentFood] {
        viewModel.getFilteredFoodTemplates(searchText: searchText)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.uniqueFoodTemplates.isEmpty {
                EmptyQuickAddView()
            } else {
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search foods...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.listBackground.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                  
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredFoods) { template in
                                QuickAddFoodCard(
                                    template: template,
                                    onTap: {
                                        onFoodSelected(template)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(Color.appBackground)
        .onAppear {
            viewModel.loadFoodTemplates()
        }
    }
}

// MARK: - Quick Add Food Card
struct QuickAddFoodCard: View {
    let template: RecentFood
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 16) {
                        NutritionBadge(
                            icon: "flame",
                            value: "\(Int(template.caloriesPer100g)) cal",
                            color: .customOrange
                        )
                        
                        NutritionBadge(
                            icon: "bolt",
                            value: "\(Int(template.proteinPer100g))g protein",
                            color: .customBlue
                        )
                    }
                    
                    HStack(spacing: 8) {
                        Text("Used \(template.timesUsed) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if template.isServingMode {
                            Text("• Serving mode")
                                .font(.caption)
                                .foregroundColor(.customOrange)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.customOrange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nutrition Badge
struct NutritionBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
    }
}

// MARK: - Empty Quick Add View
struct EmptyQuickAddView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Previous Foods")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text("Add some foods manually first, then they'll appear here for quick adding")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}
