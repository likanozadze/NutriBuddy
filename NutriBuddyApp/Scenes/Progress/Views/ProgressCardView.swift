//
//  ProgressCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//
import SwiftUI

struct ProgressCardView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            if viewModel.hasProfile {
                CalorieProgressCard(viewModel: viewModel.calorieProgressViewModel)
                
                LazyVGrid(columns: macroColumns, spacing: 16) {
                    ForEach(viewModel.macroProgressViewModel.macros, id: \.title) { macro in
                        MacroProgressCard(macro: macro)
                    }
                }
                .padding(.top, 16)
            } else {
                NoProfileCard()
                    .padding(.vertical, 16)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var macroColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}
