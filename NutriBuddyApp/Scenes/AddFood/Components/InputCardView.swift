//
//  InputCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/28/25.
//

import SwiftUI

struct InputCardView: View {
    @StateObject private var viewModel: AddFoodViewModel
    
    init(viewModel: AddFoodViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Food Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Food Name",
                    text: $viewModel.name,
                    icon: "textformat",
                    placeholder: viewModel.inputMode == .servings ? "Egg" : "Chicken breast"
                )
             
                VStack(alignment: .leading, spacing: 8) {
                    Text("AMOUNT")
                        .font(.caption)
                        .foregroundColor(.primaryText)
                        .textCase(.uppercase)
                    
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: viewModel.inputMode.icon)
                                .foregroundColor(.customBlue)
                                .font(.title3)
                            
                            if viewModel.inputMode == .grams {
                                TextField("150g", text: $viewModel.grams)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("1 serving", text: $viewModel.servingAmount)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Menu {
                            Button("Grams") { viewModel.inputMode = .grams }
                            Button("Servings") { viewModel.inputMode = .servings }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.inputMode.displayName.capitalized)
                                    .foregroundColor(.customBlue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.customBlue)
                                    .font(.caption)
                            }
                        }
                        .frame(height: 40)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(Color.listBackground.opacity(0.5))
                    .cornerRadius(8)
                }
            
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.inputMode == .servings ? "CALORIES" : "CALORIES PER 100G")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                        
                        HStack {
                            Image(systemName: "flame")
                                .foregroundColor(.customOrange)
                                .font(.body)
                            
                            if viewModel.inputMode == .servings {
                                TextField("70", text: $viewModel.servingCalories)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("165", text: $viewModel.caloriesPer100g)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color.listBackground.opacity(0.5))
                        .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.inputMode == .servings ? "PROTEIN (G)" : "PROTEIN PER 100G")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                        
                        HStack {
                            Image(systemName: "bolt")
                                .foregroundColor(.customGreen)
                                .font(.body)
                            
                            if viewModel.inputMode == .servings {
                                TextField("6", text: $viewModel.servingProtein)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("31", text: $viewModel.proteinPer100g)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color.listBackground.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}
