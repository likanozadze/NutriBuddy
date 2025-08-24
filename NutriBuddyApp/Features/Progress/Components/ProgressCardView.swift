//
//  ProgressCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct ProgressCardView: View {
    let viewModel: FoodListViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                if let profile = viewModel.currentProfile {
                   
                    CalorieProgressCard(
                        target: profile.dailyCalorieTarget,
                        eaten: viewModel.totalCalories,
                        remaining: viewModel.caloriesRemaining
                    )
    LazyVGrid(columns: macroColumns, spacing: 16) {
                        MacroProgressCard(
                            title: "Protein",
                            current: viewModel.totalProtein,
                            target: profile.proteinTarget,
                            unit: "g",
                            color: .green
                        )
                        
                        MacroProgressCard(
                            title: "Carbs",
                            current: 0,
                            target: profile.carbTarget,
                            unit: "g",
                            color: .orange
                        )
                        
//                        MacroProgressCard(
//                            title: "Fats",
//                            current: 0,
//                            target: profile.fatTarget,
//                            unit: "g",
//                            color: .pink
//                        )
//                        
//                        MacroProgressCard(
//                            title: "Fiber",
//                            current: 0,
//                            target: profile.fiberTarget,
//                            unit: "g",
//                            color: .brown
//                        )
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                } else {
                    NoProfileCard()
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 16)
         
        }
    }
    
    private var macroColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }
}
