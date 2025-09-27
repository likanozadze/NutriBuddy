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
    @State private var selectedRecentFood: RecentFood?
    
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
                                    onTap: { handleResultSelection(result) },
                                    onModifyTap: { handleModifySelection(result) }
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
        .sheet(item: $selectedRecentFood) { recentFood in
            RecentFoodPortionView(
                recentFood: recentFood,
                onSave: { modifiedFood in
                    onFoodSelected(modifiedFood)
                    self.selectedRecentFood = nil
                },
                onCancel: {
                    self.selectedRecentFood = nil
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
    
    private func handleModifySelection(_ result: FoodSearchResult) {
        switch result {
        case .local(let recentFood):
            self.selectedRecentFood = recentFood
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
    let onModifyTap: () -> Void
    
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
                
                // Modify button
                Button(action: onModifyTap) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.title3)
                        .foregroundColor(.customBlue)
                }
                .buttonStyle(.plain)
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

// MARK: - Recent Food Portion Selection View
struct RecentFoodPortionView: View {
    let recentFood: RecentFood
    let onSave: (RecentFood) -> Void
    let onCancel: () -> Void
    
    @State private var amount: String = ""
    @State private var grams: String = ""
    
    private var isServingMode: Bool {
        recentFood.isServingMode
    }
    
    private var defaultServingSize: Double {
        recentFood.servingSize ?? 100
    }
    
    private var calculatedGrams: Double {
        if isServingMode {
            guard let servingAmount = Double(amount), servingAmount > 0 else { return 0 }
            return servingAmount * defaultServingSize
        } else {
            return Double(grams) ?? 0
        }
    }
    
    private var calculatedCalories: Double {
        (recentFood.caloriesPer100g * calculatedGrams) / 100
    }
    
    private var calculatedProtein: Double {
        (recentFood.proteinPer100g * calculatedGrams) / 100
    }
    
    private var isValidInput: Bool {
        if isServingMode {
            guard let value = Double(amount) else { return false }
            return value > 0
        } else {
            guard let value = Double(grams) else { return false }
            return value > 0
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                VStack(spacing: 12) {
                    Text(recentFood.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 20) {
                        NutritionInfoCard(
                            title: "Calories",
                            value: "\(Int(recentFood.caloriesPer100g))",
                            unit: "per 100g",
                            color: .customOrange
                        )
                        
                        NutritionInfoCard(
                            title: "Protein",
                            value: "\(Int(recentFood.proteinPer100g))g",
                            unit: "per 100g",
                            color: .customBlue
                        )
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
  
                VStack(spacing: 16) {
                    if isServingMode {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "number.circle")
                                    .foregroundColor(.customOrange)
                                Text("Number of Servings")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                            }
                            
                            TextField("e.g., 1.5", text: $amount)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "scalemass")
                                    .foregroundColor(.customOrange)
                                Text("Weight in Grams")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                            }
                            
                            TextField("e.g., 150", text: $grams)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                
   
                if isValidInput {
                    VStack(spacing: 12) {
                        Text("Nutrition Preview")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(Int(calculatedCalories))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.customOrange)
                                Text("calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(calculatedProtein.formatted(.number.precision(.fractionLength(0...1))))g")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.customBlue)
                                Text("protein")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack {
                                Text("\(calculatedGrams.formatted(.number.precision(.fractionLength(0...1))))g")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.customGreen)
                                Text("total weight")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.cardBackground.opacity(0.5))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .background(Color.appBackground)
            .navigationTitle("Adjust Portion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        let modifiedFood = createModifiedFood()
                        onSave(modifiedFood)
                    }
                    .disabled(!isValidInput)
                }
            }
        }
        .onAppear {

            if isServingMode {
                amount = "1"
            } else {
                grams = "100"
            }
        }
    }
    
    private func createModifiedFood() -> RecentFood {
        return RecentFood(
            name: recentFood.name,
            caloriesPer100g: recentFood.caloriesPer100g,
            proteinPer100g: recentFood.proteinPer100g,
            carbsPer100g: recentFood.carbsPer100g,
            fatPer100g: recentFood.fatPer100g,
            fiberPer100g: recentFood.fiberPer100g,
            sugarPer100g: recentFood.sugarPer100g,
            inputMode: recentFood.inputMode,
            servingSize: calculatedGrams,
            timesUsed: recentFood.timesUsed,
            lastUsed: recentFood.lastUsed
        )
    }
}

// MARK: - Helper Views
struct NutritionInfoCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.primaryText)
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
