//
//  AmountSelector.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/27/25.
//

import SwiftUI

struct AmountSelector: View {
    @Binding var amount: Double
    @Binding var amountText: String
    @Binding var isEditingAmount: Bool
    @FocusState.Binding var isAmountFieldFocused: Bool
    @Binding var isAnimating: Bool
    
    let selectedPortionType: PortionType
    let calculatedGrams: Double
    let quickAmounts: [Double]
    let onUpdateAmount: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Amount")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {

                Button(action: decreaseAmount) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                }
                .scaleEffect(isAnimating ? 0.95 : 1.0)
                

                VStack(spacing: 4) {
                    if isEditingAmount {
                        TextField("Amount", text: $amountText)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)
                            .focused($isAmountFieldFocused)
                            .onSubmit(onUpdateAmount)
                            .padding(.horizontal, 8)
                    } else {
                        Button(action: startEditingAmount) {
                            Text(formatAmount())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                        }
                    }
                    
                    Text(selectedPortionType.unitLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if selectedPortionType != .grams {
                        Text("≈ \(Int(calculatedGrams))g")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity)
                
           
                Button(action: increaseAmount) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.secondary)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                        )
                }
                .scaleEffect(isAnimating ? 0.95 : 1.0)
            }
            

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(quickAmounts, id: \.self) { quickAmount in
                    Button(action: { selectQuickAmount(quickAmount) }) {
                        Text(formatQuickAmountText(quickAmount))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(abs(amount - quickAmount) < 0.1 ? .blue : .secondary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(abs(amount - quickAmount) < 0.1 ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(abs(amount - quickAmount) < 0.1 ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
    }
    
    private func formatAmount() -> String {
        selectedPortionType == .grams ? "\(Int(amount))" : String(format: "%.1f", amount)
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
    
    private func startEditingAmount() {
        isEditingAmount = true
        amountText = formatAmount()
        isAmountFieldFocused = true
    }
    
    private func decreaseAmount() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isAnimating = true
            let decrease: Double
            switch selectedPortionType {
            case .grams:
                decrease = 10
            case .milliliter:
                decrease = 50
            default:
                decrease = 0.1
            }
            let newAmount = max(0.1, amount - decrease)
            amount = newAmount
            amountText = formatAmount()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
    
    private func increaseAmount() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isAnimating = true
            let increase: Double
            switch selectedPortionType {
            case .grams:
                increase = 10
            case .milliliter:
                increase = 50
            default:
                increase = 0.1
            }
            let newAmount = amount + increase
            amount = newAmount
            amountText = formatAmount()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
    
    private func selectQuickAmount(_ quickAmount: Double) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isEditingAmount = false
            isAmountFieldFocused = false
            isAnimating = true
            amount = quickAmount
            amountText = formatAmount()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isAnimating = false
        }
    }
}
