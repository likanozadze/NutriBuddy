//
//  FoodListView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct FoodListView: View {
    @Query private var allFoods: [FoodEntry]
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var context
    @State private var viewModel = FoodListViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                DateNavigator(viewModel: viewModel)
                DailySummaryView(viewModel: viewModel)
                ScrollView {
                    FoodListSection(
                        foods: viewModel.dailyFoods,
                        onDelete: viewModel.deleteFoods
                    )
                }
               // .frame(height: 300)
            }
            //  .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
            //.toolbar {
//                ToolbarItem(placement: .principal) {
//                    DateNavigator(viewModel: viewModel)
//                }
          //  }
            .onAppear {
                viewModel.setup(allFoods: allFoods, profiles: profiles, context: context)
            }
            .onChange(of: allFoods) { _, newFoods in
                viewModel.setup(allFoods: newFoods, profiles: profiles, context: context)
            }
            .onChange(of: profiles) { _, newProfiles in
                viewModel.setup(allFoods: allFoods, profiles: newProfiles, context: context)
            }
        }
    }
}
