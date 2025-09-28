//
//  BarcodeResultView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import SwiftUI

struct BarcodeResultView: View {
    let barcodeFood: BarcodeFood
    let onSave: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var amount: Double
    @State private var amountText: String
    @State private var isEditingAmount = false
    @State private var isAnimating = false
    @FocusState private var isAmountFieldFocused: Bool
    
    init(barcodeFood: BarcodeFood, onSave: @escaping (Double) -> Void, onCancel: @escaping () -> Void) {
        self.barcodeFood = barcodeFood
        self.onSave = onSave
        self.onCancel = onCancel
        
        let initial = barcodeFood.defaultPortion ?? 100
        _amount = State(initialValue: initial)
        _amountText = State(initialValue: "\(Int(initial))")
    }
    
    private var nutritionData: [NutritionInfo] {
        let ratio = amount / 100
        return NutritionDataFactory.createNutritionData(for: barcodeFood, ratio: ratio)
    }
    
    private var quickAmounts: [Double] = [50, 100, 150, 200]
    

    private var hasChangedFromDefault: Bool {
        let defaultAmount = barcodeFood.defaultPortion ?? 100
        return amount != defaultAmount
    }
    
    private var isValidInput: Bool {
        amount > 0
    }
    
    var body: some View {
        StandardBackgroundView {
            VStack(spacing: 24) {
                StandardHeaderView(title: "Add Barcode Food", onCancel: onCancel)
                
                FoodInformationCard(
                    food: barcodeFood,
                    nutritionData: NutritionDataFactory.createNutritionData(for: barcodeFood, ratio: 1.0),
                    subtitle: "Per 100g serving",
                    customIcon: "barcode"
                )
                
                amountSelectionView
                
        
                if hasChangedFromDefault {
                    YourPortionPreviewCard(
                        nutritionData: nutritionData,
                        isAnimating: isAnimating
                    )
                }
                
                Spacer()
                
                StandardActionButtons(
                    onCancel: onCancel,
                    onSave: { onSave(amount) },
                    isValidInput: isValidInput
                )
            }
        }
        .onAppear {
            amountText = "\(Int(amount))"
        }
        .onTapGesture {
            if isEditingAmount {
                updateAmountFromText()
            }
        }
    }
    
    private var amountSelectionView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Amount")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                AmountSelector(
                    amount: $amount,
                    amountText: $amountText,
                    isEditingAmount: $isEditingAmount,
                    isAmountFieldFocused: $isAmountFieldFocused,
                    isAnimating: $isAnimating,
                    selectedPortionType: .grams,
                    calculatedGrams: amount,
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
}
