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
        return [
            NutritionInfo(
                label: "Calories",
                value: Int(barcodeFood.caloriesPer100g * ratio),
                baseValue: Int(barcodeFood.caloriesPer100g),
                unit: nil,
                color: LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing),
                icon: "flame.fill"
            ),
            NutritionInfo(
                label: "Protein",
                value: Int(barcodeFood.proteinPer100g * ratio),
                baseValue: Int(barcodeFood.proteinPer100g),
                unit: "g",
                color: LinearGradient(colors: [.blue, Color(red: 0.2, green: 0.4, blue: 0.8)], startPoint: .leading, endPoint: .trailing),
                icon: "bolt.fill"
            ),
            NutritionInfo(
                label: "Carbs",
                value: Int(barcodeFood.carbsPer100g * ratio),
                baseValue: Int(barcodeFood.carbsPer100g),
                unit: "g",
                color: LinearGradient(colors: [.green, Color(red: 0.2, green: 0.7, blue: 0.3)], startPoint: .leading, endPoint: .trailing),
                icon: "leaf.fill"
            ),
            NutritionInfo(
                label: "Fat",
                value: Int(barcodeFood.fatPer100g * ratio),
                baseValue: Int(barcodeFood.fatPer100g),
                unit: "g",
                color: LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing),
                icon: "drop.fill"
            )
        ]
    }
    
    private var quickAmounts: [Double] = [50, 100, 150, 200]
    
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
                    productCardView
                    amountSelectionView
                    nutritionalPreviewView
                    actionButtonsView
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
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
            
            Text("Add Barcode Food")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }
    
    private var productCardView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(barcodeFood.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        if let brand = barcodeFood.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "barcode")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                Text("Per 100g serving")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
    
    private var amountSelectionView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {

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
                onSave(amount)
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
            .scaleEffect(amount <= 0 ? 0.95 : 1.0)
            .opacity(amount <= 0 ? 0.6 : 1.0)
            .disabled(amount <= 0)
        }
        .padding(.bottom, 20)
    }
    
    private func updateAmountFromText() {
        if let newAmount = Double(amountText), newAmount > 0 {
            amount = newAmount
        }
        isEditingAmount = false
        isAmountFieldFocused = false
    }
}
