//
//  DailySummaryView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct DailySummaryView: View {
    @ObservedObject var viewModel: ProgressViewModel
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @State private var isRefreshingSteps = false
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressCardView(viewModel: viewModel)
                .padding(.bottom, 8)
            if healthKitManager.isAuthorized {
                StepsCardView(
                    steps: viewModel.stepsToday,
                    goal: viewModel.stepGoal,
                    isRefreshing: isRefreshingSteps,
                    onRefresh: refreshSteps
                )
            }
        }
        .onAppear {
           
            if viewModel.stepsToday == 0 && healthKitManager.isAuthorized {
                refreshSteps()
            }
        }
    }
    
    private func refreshSteps() {
        guard !isRefreshingSteps else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshingSteps = true
        }
        
        healthKitManager.fetchTodayStepsWithCaching { [weak viewModel] steps in
            viewModel?.stepsToday = Int(steps)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRefreshingSteps = false
                }
            }
        }
    }
}

struct StepsCardView: View {
    let steps: Int
    let goal: Int
    let isRefreshing: Bool
    let onRefresh: () -> Void
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(steps) / Double(goal))
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.customBlue)
                        .font(.title3)
                    
                    Text("Steps Today")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                }
                
                Spacer()
                
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(steps)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text("of \(goal) goal")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
               
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.customBlue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 40, height: 40)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    if isRefreshing {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.customBlue)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
