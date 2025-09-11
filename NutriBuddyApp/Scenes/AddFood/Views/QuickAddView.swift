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
    @Environment(\.colorScheme) private var colorScheme
    
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Enhanced Portion Selection View with MyFitnessPal Style
struct PortionSelectionView: View {
    let apiFood: APIFood
    let onSave: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var selectedPortionType: PortionType = .piece
    @State private var amountText = "1"
    @State private var customGramsText = "100"
    @State private var showingPortionPicker = false
    
    private var smartPortions: [PortionType] {
        let foodName = apiFood.name.lowercased()
        
        if foodName.contains("noodle") || foodName.contains("pasta") ||
            foodName.contains("spaghetti") || foodName.contains("macaroni") {
            return [.cup, .grams, .serving, .ounce]
        }
        if foodName.contains("apple") || foodName.contains("orange") ||
            foodName.contains("banana") || foodName.contains("pear") {
            return [.piece, .cup, .grams]
        }
        
        if foodName.contains("egg") {
            return [.piece, .grams]
        }
        
        if foodName.contains("chocolate") || foodName.contains("bar") ||
            foodName.contains("candy") {
            return [.piece, .grams, .ounce]
        }
        
        if foodName.contains("milk") || foodName.contains("juice") ||
            foodName.contains("water") || foodName.contains("soda") {
            return [.cup, .fluidOunce, .milliliter, .liter]
        }
        
        if foodName.contains("nuts") || foodName.contains("seeds") ||
            foodName.contains("almond") || foodName.contains("walnut") {
            return [.handful, .ounce, .tablespoon, .grams]
        }
        
        if foodName.contains("bread") || foodName.contains("rice") ||
            foodName.contains("pasta") {
            return [.slice, .cup, .grams]
        }
        
        if foodName.contains("chicken") || foodName.contains("beef") ||
            foodName.contains("fish") || foodName.contains("salmon") {
            return [.serving, .ounce, .grams]
        }
        
        return [.grams, .cup, .piece, .serving]
    }
    
    private var defaultAmount: String {
        switch selectedPortionType {
        case .piece: return "1"
        case .slice: return "1"
        case .serving: return "1"
        case .handful: return "1"
        case .cup: return "1"
        case .tablespoon: return "1"
        case .teaspoon: return "1"
        case .fluidOunce: return "8"
        case .ounce: return "1"
        case .grams: return "100"
        case .milliliter: return "250"
        case .liter: return "1"
        case .custom: return customGramsText
        }
    }
    
    private var calculatedGrams: Double {
        guard let amount = Double(amountText), amount > 0 else { return 0 }
        if selectedPortionType == .custom {
            return Double(customGramsText) ?? 0
        }
        return amount * selectedPortionType.gramsEquivalent(for: apiFood)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    foodInfoSection
                    servingSizeSelectionSection
                    amountInputSection
                    
                    if calculatedGrams > 0 {
                        nutritionalPreviewSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Add Portion")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                actionButtonsSection
            }
        }
        .onAppear {
            if let firstPortion = smartPortions.first {
                selectedPortionType = firstPortion
                amountText = defaultAmount
            }
        }
        .onChange(of: selectedPortionType) { _, newValue in
            amountText = defaultAmount
        }
        .sheet(isPresented: $showingPortionPicker) {
            PortionPickerView(
                portions: smartPortions,
                selectedPortion: $selectedPortionType,
                onDismiss: { showingPortionPicker = false }
            )
            .presentationDetents([.medium, .large])
               .presentationDragIndicator(.visible)
        }
    }
    
    private var foodInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(apiFood.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                NutritionBadge(
                    icon: "flame",
                    value: "\(Int(apiFood.caloriesPer100g)) cal/100g",
                    color: .customOrange
                )
                
                NutritionBadge(
                    icon: "bolt",
                    value: "\(Int(apiFood.proteinPer100g))g protein/100g",
                    color: .customBlue
                )
                
                if apiFood.carbsPer100g > 0 {
                    NutritionBadge(
                        icon: "leaf",
                        value: "\(Int(apiFood.carbsPer100g))g carbs/100g",
                        color: .green
                    )
                }
                
                if apiFood.fatPer100g > 0 {
                    NutritionBadge(
                        icon: "drop",
                        value: "\(Int(apiFood.fatPer100g))g fat/100g",
                        color: .yellow
                    )
                }
            }
        }
        .padding()
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(12)
    }
    
    private var servingSizeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Serving Size")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Button(action: {
                showingPortionPicker = true
            }) {
                HStack {
                    Text("\(Int(Double(amountText) ?? 1)) \(selectedPortionType.displayName.lowercased())")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.listBackground.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.customBlue, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Number of Servings")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            if selectedPortionType == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Enter grams", text: $customGramsText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .padding(.horizontal, 4)
                }
            } else {
                HStack {
                    TextField("1", text: $amountText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                    
                    Text(selectedPortionType.unitLabel)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(minWidth: 60, alignment: .leading)
                    
                    Spacer()
                }
            }
            
            if calculatedGrams > 0 && selectedPortionType != .custom {
                Text("≈ \(calculatedGrams.formatted(.number.precision(.fractionLength(0...1))))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.listBackground.opacity(0.3))
        .cornerRadius(12)
    }
    
    private var nutritionalPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Nutritional Content")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NutritionValue(
                    title: "Calories",
                    value: "\(Int((apiFood.caloriesPer100g * calculatedGrams) / 100))",
                    color: .customOrange
                )
                
                NutritionValue(
                    title: "Protein",
                    value: "\(Int((apiFood.proteinPer100g * calculatedGrams) / 100))g",
                    color: .customBlue
                )
                
                if apiFood.carbsPer100g > 0 {
                    NutritionValue(
                        title: "Carbs",
                        value: "\(Int((apiFood.carbsPer100g * calculatedGrams) / 100))g",
                        color: .green
                    )
                }
                
                if apiFood.fatPer100g > 0 {
                    NutritionValue(
                        title: "Fat",
                        value: "\(Int((apiFood.fatPer100g * calculatedGrams) / 100))g",
                        color: .yellow
                    )
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                onCancel()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.secondary.opacity(0.2))
            .foregroundColor(.primary)
            .cornerRadius(12)
            
            Button("Add Food") {
                onSave(calculatedGrams)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(calculatedGrams > 0 ? Color.calorieCardButtonBlue : Color.secondary.opacity(0.3))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(calculatedGrams <= 0)
        }
        .padding()
        .background(Color.appBackground)
    }
}


// MARK: - Portion Picker View
struct PortionPickerView: View {
    let portions: [PortionType]
    @Binding var selectedPortion: PortionType
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Select Unit")
                    .font(.headline)
                    .padding()
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .background(Color.appBackground)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(portions, id: \.self) { portion in
                        PortionRowView(portion: portion, isSelected: selectedPortion == portion)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedPortion = portion
                                onDismiss()
                            }
                    }
   
                    PortionRowView(portion: .custom, isSelected: selectedPortion == .custom)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPortion = .custom
                            onDismiss()
                        }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
            }
        }
        .background(Color.appBackground)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}


struct PortionRowView: View {
    let portion: PortionType
    let isSelected: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(portion.displayName)
                    .font(.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .customBlue : .primary)

                if portion != .custom {
                    Text("≈ \(portion.gramsEquivalent(for: APIFood(fdcId: 0, description: "", foodNutrients: [], dataType: nil, commonNames: nil, additionalDescriptions: nil)).formatted(.number.precision(.fractionLength(0...1))))g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Enter grams manually")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.customBlue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}
// MARK: - Enhanced Portion Types
enum PortionType: String, CaseIterable, Hashable {
    case piece = "piece"
    case slice = "slice"
    case serving = "serving"
    case handful = "handful"
    case cup = "cup"
    case tablespoon = "tablespoon"
    case teaspoon = "teaspoon"
    case fluidOunce = "fluidOunce"
    case ounce = "ounce"
    case grams = "grams"
    case milliliter = "milliliter"
    case liter = "liter"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .piece: return "Piece"
        case .slice: return "Slice"
        case .serving: return "Serving"
        case .handful: return "Handful"
        case .cup: return "Cup"
        case .tablespoon: return "Tbsp"
        case .teaspoon: return "Tsp"
        case .fluidOunce: return "Fl oz"
        case .ounce: return "Oz"
        case .grams: return "Grams"
        case .milliliter: return "mL"
        case .liter: return "Liter"
        case .custom: return "Custom"
        }
    }
    
    var pluralName: String {
        switch self {
        case .piece: return "pieces"
        case .slice: return "slices"
        case .serving: return "servings"
        case .handful: return "handfuls"
        case .cup: return "cups"
        case .tablespoon: return "tablespoons"
        case .teaspoon: return "teaspoons"
        case .fluidOunce: return "fluid ounces"
        case .ounce: return "ounces"
        case .grams: return "grams"
        case .milliliter: return "milliliters"
        case .liter: return "liters"
        case .custom: return "custom"
        }
    }
    
    var unitLabel: String {
        switch self {
        case .piece: return "pcs"
        case .slice: return "slices"
        case .serving: return "servings"
        case .handful: return "handfuls"
        case .cup: return "cups"
        case .tablespoon: return "tbsp"
        case .teaspoon: return "tsp"
        case .fluidOunce: return "fl oz"
        case .ounce: return "oz"
        case .grams: return "g"
        case .milliliter: return "mL"
        case .liter: return "L"
        case .custom: return "g"
        }
    }
    
    var icon: String {
        switch self {
        case .piece: return "circle.fill"
        case .slice: return "rectangle.split.3x1"
        case .serving: return "fork.knife"
        case .handful: return "hand.raised.fill"
        case .cup: return "cup.and.saucer.fill"
        case .tablespoon: return "spoon"
        case .teaspoon: return "spoon"
        case .fluidOunce: return "drop.fill"
        case .ounce: return "scalemass.fill"
        case .grams: return "scalemass"
        case .milliliter: return "drop"
        case .liter: return "bottle.fill"
        case .custom: return "scale.3d"
        }
    }
    
    func gramsEquivalent(for food: APIFood) -> Double {
        let foodName = food.name.lowercased()
        
        switch self {
        case .piece:
            if foodName.contains("egg") { return 50 }
            if foodName.contains("apple") { return 180 }
            if foodName.contains("banana") { return 120 }
            if foodName.contains("orange") { return 150 }
            if foodName.contains("chocolate") || foodName.contains("bar") { return 40 }
            if foodName.contains("cookie") { return 30 }
            return 100
            
        case .slice:
            if foodName.contains("bread") { return 25 }
            if foodName.contains("pizza") { return 80 }
            if foodName.contains("cheese") { return 20 }
            return 30
            
        case .serving:
            if foodName.contains("meat") || foodName.contains("chicken") ||
                foodName.contains("beef") || foodName.contains("fish") { return 85 }
            return 100
            
        case .handful:
            if foodName.contains("nuts") || foodName.contains("chips") { return 30 }
            return 25
            
        case .cup: return 240
        case .tablespoon: return 15
        case .teaspoon: return 5
        case .fluidOunce: return 30
        case .ounce: return 28
        case .grams: return 1
        case .milliliter: return 1
        case .liter: return 1000
        case .custom: return 1
        }
    }
}

// MARK: - Nutrition Value Component
struct NutritionValue: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Nutrition Badge (Reused from original)
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

// MARK: - Empty Quick Add View (Reused from original)
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
