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
        ScrollView {
            LazyVStack {
                ForEach(foods, id: \.id) { food in
                    NavigationLink(destination: EditFoodView(food: food)) {
                        FoodItemCard(food: food)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

struct FoodItemCard: View {
    let food: FoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(food.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                Text(amountDisplayText)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.cardBackground)
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

// MARK: - Edit Food View
struct EditFoodView: View {
    let food: FoodEntry
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPortionType: PortionType = .grams
    @State private var amount: Double = 100
    @State private var showingPortionPicker = false
    @State private var isAnimating = false
    @State private var isEditingAmount = false
    @State private var amountText = ""
    @FocusState private var isAmountFieldFocused: Bool
    
    private var calculatedGrams: Double {
        selectedPortionType == .grams ? amount : amount * selectedPortionType.gramsEquivalent(for: createAPIFoodFromFoodEntry())
    }
    
    private var ratio: Double {
        calculatedGrams / 100.0
    }
    
    private var nutritionData: [NutritionInfo] {
        NutritionDataFactory.createNutritionData(for: food, ratio: ratio)
    }
    
    private var quickAmounts: [Double] {
        selectedPortionType == .grams ? [50, 100, 150, 200] : [0.5, 1, 1.5, 2]
    }
    
    private var defaultAmountForPortionType: Double {
        switch selectedPortionType {
        case .grams:
            return food.grams
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
    
    private var hasChangedFromOriginal: Bool {
        calculatedGrams != food.grams
    }
    
    private var isValidInput: Bool {
        calculatedGrams > 0
    }
    
    var body: some View {
        StandardBackgroundView {
            VStack(spacing: 24) {
                FoodInformationCard(
                    food: food,
                    nutritionData: NutritionDataFactory.createNutritionData(for: food, ratio: 1.0),
                    subtitle: "Per 100g • Current:\(food.grams.asGramString)",
                    customIcon: "pencil"
                )
                
                portionSelectionView
                
                if hasChangedFromOriginal {
                    YourPortionPreviewCard(
                        nutritionData: nutritionData,
                        isAnimating: isAnimating
                    )
                }
                
                Spacer()
                
                StandardActionButtons(
                    onCancel: { dismiss() },
                    onSave: saveChanges,
                    isValidInput: isValidInput,
                    saveButtonText: "Update Food"
                )
            }
        }
        .navigationTitle("Edit Food")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showingPortionPicker) {
            ModernPortionPickerView(
                selectedPortion: $selectedPortionType,
                onDismiss: { showingPortionPicker = false }
            )
        }
        .onAppear {
            setupInitialValues()
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
                Text("Adjust Serving Size")
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
    
    private func setupInitialValues() {
        selectedPortionType = .grams
        amount = food.grams
        amountText = "\(Int(amount))"
    }
    
    private func updateAmountFromText() {
        if let newAmount = Double(amountText), newAmount > 0 {
            amount = newAmount
        }
        isEditingAmount = false
        isAmountFieldFocused = false
    }
    
    private func saveChanges() {
        food.grams = calculatedGrams
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to update food: \(error)")
        }
    }
    
    private func createAPIFoodFromFoodEntry() -> APIFood {
        return APIFood(
            fdcId: 0,
            description: food.name,
            foodNutrients: [],
            dataType: nil,
            commonNames: nil,
            additionalDescriptions: nil
        )
    }
}

struct EmptyFoodLogView: View {
    let onAddFood: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: { onAddFood() }) {
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("No food logged yet")
                            .font(.headline)
                            .foregroundColor(.primaryText)
                        
                        Text("Tap + to start tracking your meals")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .buttonStyle(.plain)
            
            Color.clear
                .frame(height: 80)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

extension Double {
    var clean: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

// MARK: - Make FoodEntry conform to FoodDisplayable
extension FoodEntry: FoodDisplayable {
    var brand: String? { nil }
}
