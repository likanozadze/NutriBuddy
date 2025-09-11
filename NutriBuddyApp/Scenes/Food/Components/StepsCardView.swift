//
//  DailySummaryView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//
import SwiftUI

struct StepsCardView: View {
    let steps: Int
    let goal: Int
    let isRefreshing: Bool
    let onRefresh: () -> Void
    
    private var progress: Double {
        let safeGoal = max(1, goal)
        let safeSteps = max(0, steps)
        let value = Double(safeSteps) / Double(safeGoal)
        return min(1.0, max(0.0, value))
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

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
