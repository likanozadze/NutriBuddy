//
//  QuickAddView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.

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
        StandardBackgroundView {
            if viewModel.uniqueFoodTemplates.isEmpty && viewModel.searchResults.isEmpty {
                EmptyQuickAddView()
            } else {
                VStack(spacing: 20) {
                    ModernSearchBar(searchText: $searchText, isSearching: viewModel.isSearching)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.searchResults) { result in
                            ModernSearchResultCard(
                                result: result,
                                onTap: { handleResultSelection(result) },
                                onModifyTap: { handleModifySelection(result) }
                            )
                        }
                    }
                }
            }
        }
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
            NavigationStack {
                ModernPortionSelectionView(
                    apiFood: apiFood,
                    onSave: { grams in
                        viewModel.addAPIFood(apiFood, grams: grams)
                        self.selectedAPIFood = nil
                    },
                    onCancel: {
                        self.selectedAPIFood = nil
                    }
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
        }
        .sheet(item: $selectedRecentFood) { recentFood in
            ModernRecentFoodPortionView(
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
            .interactiveDismissDisabled(false)
        }
    }
    
    private func handleResultSelection(_ result: FoodSearchResult) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch result {
            case .local(let recentFood):
                onFoodSelected(recentFood)
            case .api(let apiFood):
                self.selectedAPIFood = apiFood
            }
        }
    }
    
    private func handleModifySelection(_ result: FoodSearchResult) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch result {
            case .local(let recentFood):
                self.selectedRecentFood = recentFood
            case .api(let apiFood):
                self.selectedAPIFood = apiFood
            }
        }
    }
}

// MARK: - Modern Search Bar
struct ModernSearchBar: View {
    @Binding var searchText: String
    let isSearching: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
            
            TextField("Search foods...", text: $searchText)
                .textFieldStyle(.plain)
                .focused($isTextFieldFocused)
                .onSubmit {
                    isTextFieldFocused = false
                }
            
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            } else if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isTextFieldFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
}

// MARK: - Modern Search Result Card
struct ModernSearchResultCard: View {
    let result: FoodSearchResult
    let onTap: () -> Void
    let onModifyTap: () -> Void
    
    private var nutritionData: [NutritionInfo] {
        switch result {
        case .local(let recentFood):
            return NutritionDataFactory.createNutritionData(for: recentFood, ratio: 1.0)
        case .api(let apiFood):
            return NutritionDataFactory.createNutritionData(for: apiFood, ratio: 1.0)
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Header Section
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(result.name)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if case .api(_) = result {
                                Text("Database")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.blue.opacity(0.1))
                                            .overlay(
                                                Capsule()
                                                    .stroke(.blue.opacity(0.3), lineWidth: 1)
                                            )
                                    )
                                    .foregroundColor(.blue)
                            }
                        }
                        
                       
                        if case .local(let recentFood) = result {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("Used \(recentFood.timesUsed) times")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if recentFood.isServingMode {
                                    Text("• Serving mode")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "globe")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                Text("From food database")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                  
                    Button(action: onModifyTap) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(.blue.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(.blue.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                
   
                HStack(spacing: 16) {
                    ForEach(Array(nutritionData.prefix(4)), id: \.label) { info in
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: info.icon)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(info.baseValue)\(info.unit ?? "")")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                            }
                            Text(info.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Modern API Food Portion Selection
struct ModernPortionSelectionView: View {
    let apiFood: APIFood
    let onSave: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var grams: String = "100"
    @FocusState private var isInputFocused: Bool
    
    private var gramsValue: Double {
        Double(grams) ?? 0
    }
    
    private var ratio: Double {
        gramsValue / 100.0
    }
    
    private var nutritionData: [NutritionInfo] {
        NutritionDataFactory.createNutritionData(for: apiFood, ratio: ratio)
    }
    
    private var isValidInput: Bool {
        gramsValue > 0
    }
    
    var body: some View {
        StandardBackgroundView {
            VStack(spacing: 24) {
                StandardHeaderView(title: "Select Portion", onCancel: onCancel)
                
                FoodInformationCard(
                    food: apiFood,
                    nutritionData: NutritionDataFactory.createNutritionData(for: apiFood, ratio: 1.0),
                    customIcon: "globe"
                )
                
                ModernWeightInputCard(
                    grams: $grams,
                    isInputFocused: $isInputFocused
                )
                
                if isValidInput {
                    YourPortionPreviewCard(
                        nutritionData: nutritionData,
                        isAnimating: true
                    )
                }
                
                Spacer()
                
                StandardActionButtons(
                    onCancel: onCancel,
                    onSave: { onSave(gramsValue) },
                    isValidInput: isValidInput
                )
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
}

// MARK: - Modern Recent Food Portion View
struct ModernRecentFoodPortionView: View {
    let recentFood: RecentFood
    let onSave: (RecentFood) -> Void
    let onCancel: () -> Void
    
    @State private var amount: String = ""
    @State private var grams: String = ""
    @FocusState private var isInputFocused: Bool
    
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
    
    private var ratio: Double {
        calculatedGrams / 100.0
    }
    
    private var nutritionData: [NutritionInfo] {
        NutritionDataFactory.createNutritionData(for: recentFood, ratio: ratio)
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
        StandardBackgroundView {
            VStack(spacing: 24) {
                StandardHeaderView(title: "Adjust Portion", onCancel: onCancel)
                
                FoodInformationCard(
                    food: recentFood,
                    nutritionData: NutritionDataFactory.createNutritionData(for: recentFood, ratio: 1.0),
                    subtitle: "Per 100g serving • Used \(recentFood.timesUsed) times",
                    customIcon: "clock.arrow.circlepath"
                )
                
                if isServingMode {
                    ModernServingInputCard(
                        amount: $amount,
                        servingSize: defaultServingSize,
                        isInputFocused: $isInputFocused
                    )
                } else {
                    ModernWeightInputCard(
                        grams: $grams,
                        isInputFocused: $isInputFocused
                    )
                }
                
                if isValidInput {
                    YourPortionPreviewCard(
                        nutritionData: nutritionData,
                        isAnimating: true
                    )
                }
                
                Spacer()
                
                StandardActionButtons(
                    onCancel: onCancel,
                    onSave: { onSave(createModifiedFood()) },
                    isValidInput: isValidInput
                )
            }
        }
        .onAppear {
            if isServingMode {
                amount = "1"
            } else {
                grams = "100"
            }
        }
        .onTapGesture {
            isInputFocused = false
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

// MARK: - Modern Input Cards
struct ModernWeightInputCard: View {
    @Binding var grams: String
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "scalemass")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                Text("Weight in Grams")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            TextField("e.g., 150", text: $grams)
                .font(.title2)
                .fontWeight(.medium)
                .keyboardType(.decimalPad)
                .focused($isInputFocused)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isInputFocused ? .blue : .clear, lineWidth: 2)
                        )
                )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

struct ModernServingInputCard: View {
    @Binding var amount: String
    let servingSize: Double
    @FocusState.Binding var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "number.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
                Text("Number of Servings")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                TextField("e.g., 1.5", text: $amount)
                    .font(.title2)
                    .fontWeight(.medium)
                    .keyboardType(.decimalPad)
                    .focused($isInputFocused)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isInputFocused ? .orange : .clear, lineWidth: 2)
                            )
                    )
                
                Text("1 serving = \(servingSize.formatted(.number.precision(.fractionLength(0...1))))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Empty Quick Add View (Updated)
struct EmptyQuickAddView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.6))
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                )
            
            VStack(spacing: 12) {
                Text("No Previous Foods")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Add some foods manually first, or search for foods from our database")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 80)
    }
}
