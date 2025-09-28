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
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled(false)
        }
        .sheet(item: $selectedRecentFood) { recentFood in
            NavigationStack {
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
            }
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
                        }
                        
                       
                        if case .local(let recentFood) = result {
                            HStack(spacing: 8) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("Recently used")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if recentFood.isServingMode {
                                    Text("• Serving mode")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
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
                                    .foregroundColor(getIconColor(for: info.label))
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
    
    private func getIconColor(for label: String) -> Color {
        switch label {
        case "Calories":
            return .orange
        case "Protein":
            return .blue
        case "Carbs":
            return .green
        case "Fat":
            return .yellow
        default:
            return .secondary
        }
    }
}

// MARK: - Modern Recent Food Portion View
struct ModernRecentFoodPortionView: View {
    let recentFood: RecentFood
    let onSave: (RecentFood) -> Void
    let onCancel: () -> Void
    
    @State private var selectedPortionType: PortionType = .grams
    @State private var amount: Double = 100
    @State private var showingPortionPicker = false
    @State private var isAnimating = false
    @State private var isEditingAmount = false
    @State private var amountText = ""
    @FocusState private var isAmountFieldFocused: Bool
    
    private var calculatedGrams: Double {
        selectedPortionType == .grams ? amount : amount * selectedPortionType.gramsEquivalent(for: createAPIFoodFromRecentFood())
    }
    
    private var ratio: Double {
        calculatedGrams / 100.0
    }
    
    private var nutritionData: [NutritionInfo] {
        NutritionDataFactory.createNutritionData(for: recentFood, ratio: ratio)
    }
    
    private var quickAmounts: [Double] {
        selectedPortionType == .grams ? [50, 100, 150, 200] : [0.5, 1, 1.5, 2]
    }
    
    private var defaultAmountForPortionType: Double {
        switch selectedPortionType {
        case .grams:
            return recentFood.servingSize ?? 100
        case .piece, .slice, .serving, .handful:
            return 1
        case .cup, .tablespoon, .teaspoon, .ounce, .fluidOunce, .liter:
            return 1
        case .milliliter:
            return 250
        case .custom:
            return 100
        }
    }
    
    private var isValidInput: Bool {
        calculatedGrams > 0
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
                
                portionSelectionView
                
                if isValidInput && calculatedGrams != (recentFood.servingSize ?? 100) {
                    YourPortionPreviewCard(
                        nutritionData: nutritionData,
                        isAnimating: isAnimating
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
        .sheet(isPresented: $showingPortionPicker) {
            ModernPortionPickerView(
                selectedPortion: $selectedPortionType,
                onDismiss: { showingPortionPicker = false }
            )
        }
        .onAppear {
            if recentFood.isServingMode {
                selectedPortionType = .serving
                amount = 1
            } else {
                selectedPortionType = .grams
                amount = recentFood.servingSize ?? 100
            }
            amountText = selectedPortionType == .grams ? "\(Int(amount))" : String(format: "%.1f", amount)
        }
        .onChange(of: selectedPortionType) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                amount = defaultAmountForPortionType
                amountText = selectedPortionType == .grams ? "\(Int(amount))" : String(format: "%.1f", amount)
            }
        }
        .onTapGesture {
            if isEditingAmount {
                updateAmountFromText()
            }
        }
    }
    
    private var portionSelectionView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Serving Size")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showingPortionPicker.toggle()
                    }
                }) {
                    HStack(spacing: 12) {
                        Text(selectedPortionType.emoji)
                            .font(.title2)
                        
                        Text(selectedPortionType.displayName)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(showingPortionPicker ? 180 : 0))
                            .animation(.easeInOut(duration: 0.3), value: showingPortionPicker)
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [.blue, Color(red: 0.2, green: 0.4, blue: 0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
                }
                
                AmountSelector(
                    amount: $amount,
                    amountText: $amountText,
                    isEditingAmount: $isEditingAmount,
                    isAmountFieldFocused: $isAmountFieldFocused,
                    isAnimating: $isAnimating,
                    selectedPortionType: selectedPortionType,
                    calculatedGrams: calculatedGrams,
                    quickAmounts: quickAmounts,
                    onUpdateAmount: updateAmountFromText
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
    
    private func updateAmountFromText() {
        if let newAmount = Double(amountText), newAmount > 0 {
            amount = newAmount
        }
        isEditingAmount = false
        isAmountFieldFocused = false
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
    
    private func createAPIFoodFromRecentFood() -> APIFood {
        return APIFood(
            fdcId: 0,
            description: recentFood.name,
            foodNutrients: [],
            dataType: nil,
            commonNames: nil,
            additionalDescriptions: nil
        )
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
