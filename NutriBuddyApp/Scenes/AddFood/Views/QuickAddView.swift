//
//  QuickAddView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.
//

import SwiftUI

// MARK: - QuickAddView
struct QuickAddView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    let onFoodSelected: (RecentFood) -> Void
    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?

    @State private var selectedAPIFood: APIFood?
    
    var body: some View {
        VStack(spacing: 16) {
            if viewModel.uniqueFoodTemplates.isEmpty && viewModel.searchResults.isEmpty {
                EmptyQuickAddView()
            } else {
                VStack(spacing: 12) {
                    SearchBar(searchText: $searchText, isSearching: viewModel.isSearching)
                    
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.searchResults) { result in
                                SearchResultCard(
                                    result: result,
                                    onTap: { handleResultSelection(result) }
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
            Task {
                await viewModel.loadFoodTemplates()
                await viewModel.searchFoods(searchText: searchText)
            }
        }
        .onChange(of: searchText) { _, newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 500_000_000)
                if !Task.isCancelled {
                    await viewModel.searchFoods(searchText: newValue)
                }
            }
        }

        .sheet(item: $selectedAPIFood) { apiFood in
            PortionSelectionView(
                apiFood: apiFood,
                onSave: { grams in
                    viewModel.addAPIFood(apiFood, grams: grams)
    
                    self.selectedAPIFood = nil
                },
                onCancel: {
                    self.selectedAPIFood = nil
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func handleResultSelection(_ result: FoodSearchResult) {

        switch result {
        case .local(let recentFood):
            onFoodSelected(recentFood)
        case .api(let apiFood):
            self.selectedAPIFood = apiFood
        }
    }
}

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var searchText: String
    let isSearching: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search foods...", text: $searchText)
                .textFieldStyle(.plain)
            
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

// MARK: - Search Result Card
struct SearchResultCard: View {
    let result: FoodSearchResult
    let onTap: () -> Void
  
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(result.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryText)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if case .api(_) = result {
                            Text("API")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.customBlue.opacity(0.2))
                                .foregroundColor(.customBlue)
                                .cornerRadius(4)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        NutritionBadge(
                            icon: "flame",
                            value: "\(Int(result.caloriesPer100g)) cal/100g",
                            color: .customOrange
                        )
                        
                        NutritionBadge(
                            icon: "bolt",
                            value: "\(Int(result.proteinPer100g))g protein/100g",
                            color: .customBlue
                        )
                    }
                    
                    if case .local(let recentFood) = result {
                        HStack(spacing: 8) {
                            Text("Used \(recentFood.timesUsed) times")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if recentFood.isServingMode {
                                Text("• Serving mode")
                                    .font(.caption)
                                    .foregroundColor(.customOrange)
                            }
                        }
                    } else {
                        Text("From food database")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.customOrange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

//// MARK: - Nutrition Badge
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
                
                Text("Add some foods manually first, or search for foods from our database")
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
