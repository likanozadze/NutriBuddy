//
//  DateNavigator.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct DateNavigator: View {
    let viewModel: FoodListViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            NavigationButton(direction: .previous) {
                viewModel.navigateDate(by: -1)
            }
            
            DateLabel(text: viewModel.formattedDate)
            
            NavigationButton(direction: .next) {
                viewModel.navigateDate(by: 1)
            }
        }
    }
}
