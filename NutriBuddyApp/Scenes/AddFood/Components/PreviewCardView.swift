//
//  PreviewCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/28/25.
//

import SwiftUI

struct PreviewCardView: View {
    @StateObject private var viewModel: AddFoodViewModel
    
    init(viewModel: AddFoodViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.customBlue)
                    .font(.title3)
                Text("Nutrition Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MacroPreviewItem(
                        title: "Calories",
                        value: viewModel.calculatedCalories.asCalorieString,
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    MacroPreviewItem(
                        title: "Protein",
                        value: viewModel.calculatedProtein.asProteinString,
                        icon: "bolt.fill",
                        color: .green
                    )
                }
                
                if viewModel.showAdvancedOptions {
                    if viewModel.calculatedCarbs > 0 || viewModel.calculatedFat > 0 {
                        HStack(spacing: 20) {
                            if viewModel.calculatedCarbs > 0 {
                                MacroPreviewItem(
                                    title: "Carbs",
                                    value: viewModel.calculatedCarbs.asProteinString,
                                    icon: "leaf.fill",
                                    color: .blue
                                )
                            }
                            if viewModel.calculatedFat > 0 {
                                MacroPreviewItem(
                                    title: "Fat",
                                    value: viewModel.calculatedFat.asProteinString,
                                    icon: "drop.fill",
                                    color: .purple
                                )
                            }
                        }
                    }
                    
                    if viewModel.calculatedFiber > 0 || viewModel.calculatedSugar > 0 {
                        HStack(spacing: 20) {
                            if viewModel.calculatedFiber > 0 {
                                MacroPreviewItem(
                                    title: "Fiber",
                                    value: viewModel.calculatedFiber.asProteinString,
                                    icon: "scissors",
                                    color: .brown
                                )
                            }
                            if viewModel.calculatedSugar > 0 {
                                MacroPreviewItem(
                                    title: "Sugar",
                                    value: viewModel.calculatedSugar.asProteinString,
                                    icon: "cube.fill",
                                    color: .pink
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}
