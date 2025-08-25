//
//  DailySummaryView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//


import SwiftUI

struct DailySummaryView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    var body: some View {
        ProgressCardView(viewModel: viewModel)
            .padding(.bottom, 8)
    }
}
