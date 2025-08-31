//
//  AdvancedMacrosCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/28/25.
//

import SwiftUI

struct AdvancedMacrosCardView: View {
    @ObservedObject var viewModel: AddFoodViewModel

    init(viewModel: AddFoodViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(.customGreen)
                    .font(.title3)
                Text("Additional Macros")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if viewModel.inputMode == .servings {
                    HStack(spacing: 12) {
                        AppTextField(
                            title: "CARBS/SERVING",
                            text: $viewModel.servingCarbs,
                            icon: "leaf",
                            placeholder: "0.5",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                        
                        AppTextField(
                            title: "FAT/SERVING",
                            text: $viewModel.servingFat,
                            icon: "drop",
                            placeholder: "5",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                    }
                    
                    HStack(spacing: 12) {
                        AppTextField(
                            title: "FIBER/SERVING",
                            text: $viewModel.servingFiber,
                            icon: "scissors",
                            placeholder: "0",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                        
                        AppTextField(
                            title: "SUGAR/SERVING",
                            text: $viewModel.servingSugar,
                            icon: "cube.transparent",
                            placeholder: "0.4",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                    }
                } else {
                    HStack(spacing: 12) {
                        AppTextField(
                            title: "CARBS/100G",
                            text: $viewModel.carbsPer100g,
                            icon: "leaf",
                            placeholder: "0",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                        
                        AppTextField(
                            title: "FAT/100G",
                            text: $viewModel.fatPer100g,
                            icon: "drop",
                            placeholder: "3.6",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                    }
                    
                    HStack(spacing: 12) {
                        AppTextField(
                            title: "FIBER/100G",
                            text: $viewModel.fiberPer100g,
                            icon: "scissors",
                            placeholder: "2.5",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                        
                        AppTextField(
                            title: "SUGAR/100G",
                            text: $viewModel.sugarPer100g,
                            icon: "cube.transparent",
                            placeholder: "4.7",
                            keyboardType: .decimalPad,
                            style: .compact
                        )
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
}

struct AdvancedMacrosSection: View {
    @ObservedObject var viewModel: AddFoodViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.showAdvancedOptions.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.customBlue)
                        .rotationEffect(.degrees(viewModel.showAdvancedOptions ? 90 : 0))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.showAdvancedOptions)
                    
                    Text("Advanced Macros")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    Text("Optional")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.cardBackground)
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if viewModel.showAdvancedOptions {
                AdvancedMacrosCardView(viewModel: viewModel)
            }
        }
    }
}
