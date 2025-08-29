//
//  ManualAddView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.

import SwiftUI

struct ManualAddView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    let onSave: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderCardView()
                InputCardView(viewModel: viewModel)
                AdvancedMacrosSection(viewModel: viewModel)
                PreviewCardView(viewModel: viewModel)
                SaveButton(
                    isEnabled: viewModel.isValidForm,
                    action: {
                        viewModel.saveFood()
                        onSave()
                    }
                )
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color.appBackground)
        .onAppear {
            viewModel.loadFoodTemplates()
        }
    }
}
