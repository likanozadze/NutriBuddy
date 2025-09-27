//
//  PortionSelectionView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/27/25.
//


import SwiftUI

struct PortionSelectionView: View {
    let apiFood: APIFood
    let onSave: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var selectedPortionType: PortionType = .grams
    @State private var amount: Double = 100
    @State private var showingPortionPicker = false
    @State private var isAnimating = false
    @State private var isEditingAmount = false
    @State private var amountText = ""
    @FocusState private var isAmountFieldFocused: Bool
    
    private var calculatedGrams: Double {
        selectedPortionType == .grams ? amount : amount * selectedPortionType.gramsEquivalent(for: apiFood)
    }
    
    private var ratio: Double {
        calculatedGrams / 100
    }
    
    private var nutritionData: [NutritionInfo] {
        [
            NutritionInfo(
                label: "Calories",
                value: Int(apiFood.caloriesPer100g * ratio),
                baseValue: Int(apiFood.caloriesPer100g),
                unit: nil,
                color: LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                icon: "flame.fill"
            ),
            NutritionInfo(
                label: "Protein",
                value: Int(apiFood.proteinPer100g * ratio),
                baseValue: Int(apiFood.proteinPer100g),
                unit: "g",
                color: LinearGradient(colors: [.blue, Color(red: 0.2, green: 0.4, blue: 0.8)], startPoint: .leading, endPoint: .trailing),
                icon: "bolt.fill"
            ),
            NutritionInfo(
                label: "Carbs",
                value: Int(apiFood.carbsPer100g * ratio),
                baseValue: Int(apiFood.carbsPer100g),
                unit: "g",
                color: LinearGradient(colors: [.green, Color(red: 0.2, green: 0.7, blue: 0.3)], startPoint: .leading, endPoint: .trailing),
                icon: "leaf.fill"
            ),
            NutritionInfo(
                label: "Fat",
                value: Int(apiFood.fatPer100g * ratio),
                baseValue: Int(apiFood.fatPer100g),
                unit: "g",
                color: LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                icon: "drop.fill"
            )
        ]
    }
    
    private var quickAmounts: [Double] {
        selectedPortionType == .grams ? [50, 100, 150, 200] : [0.5, 1, 1.5, 2]
    }
    
    private var defaultAmountForPortionType: Double {
        switch selectedPortionType {
        case .grams:
            let foodName = apiFood.name.lowercased()
            if foodName.contains("snickers") || foodName.contains("candy") || foodName.contains("chocolate bar") {
                return 30
            }
            if foodName.contains("apple") { return 180 }
            if foodName.contains("banana") { return 120 }
            if foodName.contains("egg") { return 50 }
            return 100
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
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemGray5).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    foodCardView
                    portionSelectionView
                    nutritionalPreviewView
                    actionButtonsView
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showingPortionPicker) {
            ModernPortionPickerView(
                selectedPortion: $selectedPortionType,
                onDismiss: { showingPortionPicker = false }
            )
        }
        .onAppear {
            amount = defaultAmountForPortionType
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
    
    private var headerView: some View {
        HStack {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                    )
            }
            
            Spacer()
            
            Text("Add Portion")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }
    
    private var foodCardView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(apiFood.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Per 100g serving")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            UniformNutritionGrid(nutritionData: nutritionData, showBaseValues: true)
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
    
    private var nutritionalPreviewView: some View {
        VStack(spacing: 16) {
            Text("Your Portion")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            UniformNutritionGrid(nutritionData: nutritionData, showBaseValues: false, isAnimating: isAnimating)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.1),
                            Color(.systemTeal).opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .green.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
    
    private var actionButtonsView: some View {
        HStack(spacing: 16) {
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
            
            Button(action: {
                onSave(calculatedGrams)
            }) {
                Text("Add Food")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
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
            .scaleEffect(calculatedGrams <= 0 ? 0.95 : 1.0)
            .opacity(calculatedGrams <= 0 ? 0.6 : 1.0)
            .disabled(calculatedGrams <= 0)
        }
        .padding(.bottom, 20)
    }
    
    private func formatQuickAmountText(_ amount: Double) -> String {
        switch selectedPortionType {
        case .grams:
            return "\(Int(amount))g"
        case .milliliter:
            return "\(Int(amount))mL"
        default:
            if amount == floor(amount) {
                return "\(Int(amount)) \(selectedPortionType.unitLabel)"
            } else {
                return String(format: "%.1f %@", amount, selectedPortionType.unitLabel)
            }
        }
    }
    
    private func updateAmountFromText() {
        if let newAmount = Double(amountText), newAmount > 0 {
            amount = newAmount
        }
        isEditingAmount = false
        isAmountFieldFocused = false
    }
}




// MARK: - Portion Type Enum
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
    
    var emoji: String {
        switch self {
        case .piece: return "🍎"
        case .slice: return "🍞"
        case .serving: return "🍽️"
        case .handful: return "🤏"
        case .cup: return "☕"
        case .tablespoon: return "🥄"
        case .teaspoon: return "🥄"
        case .fluidOunce: return "💧"
        case .ounce: return "⚖️"
        case .grams: return "⚖️"
        case .milliliter: return "💧"
        case .liter: return "🫙"
        case .custom: return "⚙️"
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
