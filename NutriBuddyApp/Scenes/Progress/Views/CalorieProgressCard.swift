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
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.white.opacity(0.9))
                            .font(.title3)
                        
                        Text("Your Progress")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text("\(viewModel.progress.progressPercentage)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target: \(viewModel.targetText)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Eaten: \(viewModel.eatenText)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
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

