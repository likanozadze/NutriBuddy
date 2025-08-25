//
//  CalorieProgressCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct CalorieProgressCard: View {
    @ObservedObject var viewModel: CalorieProgressViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.gradientStart,
                    Color.gradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.gradientSecondaryText)
                            .font(.title3)
                        
                        Text("Your Progress")
                            .font(.subheadline)
                            .foregroundColor(.gradientSecondaryText)
                    }
                    
                    Text("\(viewModel.progress.progressPercentage)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.gradientPrimaryText)
                    
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gradientTertiaryText)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target: \(viewModel.targetText)")
                            .font(.caption)
                            .foregroundColor(.gradientSecondaryText)
                        
                        Text("Eaten: \(viewModel.eatenText)")
                            .font(.caption)
                            .foregroundColor(.gradientSecondaryText)
                    }
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: viewModel.progress.progress,
                    value: Int(viewModel.progress.eaten),
                    label: "Calories"
                )
            }
            .padding(20)
        }
    }
}
