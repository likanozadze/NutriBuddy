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
        VStack(spacing: 20) {
            if viewModel.hasProfile {
                CalorieProgressCard(viewModel: viewModel.calorieProgressViewModel)
                
                LazyVGrid(columns: macroColumns, spacing: 16) {
                    ForEach(viewModel.macroProgressViewModel.macros, id: \.title) { macro in
                        MacroProgressCard(macro: macro)
                    }
                }
            } else {
                NoProfileCard()
            }
        }
    }
    private var macroColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}
