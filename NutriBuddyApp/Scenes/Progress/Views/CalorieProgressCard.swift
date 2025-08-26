////
////  CalorieProgressCard.swift
////  NutriBuddyApp
////
////  Created by Lika Nozadze on 8/24/25.
////
//
//import SwiftUI
//
//struct CalorieProgressCard: View {
//    @ObservedObject var viewModel: CalorieProgressViewModel
//    
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color.gradientStart,
//                    Color.gradientEnd
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//            
//            HStack {
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack {
//                        Image(systemName: "target")
//                            .foregroundColor(.gradientSecondaryText)
//                            .font(.title3)
//                        
//                        Text("Your Progress")
//                            .font(.subheadline)
//                            .foregroundColor(.gradientSecondaryText)
//                    }
//                    
//                    Text("\(viewModel.progress.progressPercentage)%")
//                        .font(.system(size: 36, weight: .bold, design: .rounded))
//                        .foregroundColor(.gradientPrimaryText)
//                    
//                    Text(viewModel.formattedDate)
//                        .font(.caption)
//                        .foregroundColor(.gradientTertiaryText)
//                    
//                    Spacer()
//                    
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("Goal: \(viewModel.targetText)")
//                            .font(.caption)
//                            .foregroundColor(.gradientSecondaryText)
//                    
//                        Text("Remaining: \(viewModel.remainingText)")
//                            .font(.caption)
//                            .foregroundColor(.gradientSecondaryText)
//                    }
//                }
//                
//                Spacer()
//                
//                CircularProgressView(
//                    progress: viewModel.progress.progress,
//                    value: Int(viewModel.progress.eaten),
//                    label: "Calories"
//                )
//            }
//            .padding(20)
//        }
//    }
//}
//
//  CalorieProgressCard.swift
//  NutriBuddyApp
//
//  Enhanced with overeating visual indicators
//


import SwiftUI

struct CalorieProgressCard: View {
    @ObservedObject var viewModel: CalorieProgressViewModel
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            if isOvereating {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.red, lineWidth: 3)
                    .opacity(pulseOpacity)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseOpacity)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: progressIcon)
                            .foregroundColor(iconColor)
                            .font(.title3)
                            .symbolEffect(.bounce, value: isOvereating)
                        
                        Text(progressTitle)
                            .font(.subheadline)
                            .foregroundColor(.gradientSecondaryText)
                    }
                    
                    Text(progressPercentageText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(progressTextColor)
                        .scaleEffect(isOvereating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isOvereating)
                    
                    Text(viewModel.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gradientTertiaryText)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Goal: \(viewModel.targetText)")
                            .font(.caption)
                            .foregroundColor(.gradientSecondaryText)
                    
                        Text(remainingText)
                            .font(.caption)
                            .foregroundColor(remainingTextColor)
                            .fontWeight(isWarningZone ? .bold : .regular)
                    }
                    
                    
                    if isWarningZone {
                        HStack {
                            Image(systemName: warningIcon)
                                .foregroundColor(warningColor)
                                .font(.caption)
                            Text(warningMessage)
                                .font(.caption2)
                                .foregroundColor(warningColor)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 2)
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
        .onAppear {
            if isOvereating {
                pulseOpacity = 0.8
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var remainingCalories: Int {
        Int(viewModel.progress.target - viewModel.progress.eaten)
    }
    
    private var progressState: ProgressState {
        let percentage = (viewModel.progress.eaten / viewModel.progress.target) * 100
        
        if viewModel.progress.eaten > viewModel.progress.target {
            return .overeating
        } else if percentage >= 90 {
            return .almostComplete
        } else if percentage >= 75 {
            return .onTrack
        } else {
            return .normal
        }
    }
    
    private var isOvereating: Bool {
        progressState == .overeating
    }
    
    private var isWarningZone: Bool {
        progressState == .almostComplete || progressState == .overeating
    }
    
    private enum ProgressState {
        case normal
        case onTrack
        case almostComplete
        case overeating
    }
    
    @State private var pulseOpacity: Double = 0.3
    
    private var gradientColors: [Color] {
        switch progressState {
        case .normal:
            return [Color.gradientStart, Color.gradientEnd]
        case .onTrack:
            return [Color.green.opacity(0.6), Color.mint.opacity(0.7)]
        case .almostComplete:
            return [Color.orange.opacity(0.6), Color.yellow.opacity(0.7)] 
        case .overeating:
            return [Color.red.opacity(0.7), Color.pink.opacity(0.6)]
        }
    }
    
    private var progressIcon: String {
        switch progressState {
        case .normal:
            return "target"
        case .onTrack:
            return "checkmark.circle.fill"
        case .almostComplete:
            return "clock.fill"
        case .overeating:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color {
        switch progressState {
        case .normal:
            return .gradientSecondaryText
        case .onTrack:
            return .green
        case .almostComplete:
            return .orange
        case .overeating:
            return .red
        }
    }
    
    private var progressTitle: String {
        switch progressState {
        case .normal:
            return "Your Progress"
        case .onTrack:
            return "Great Progress!"
        case .almostComplete:
            return "Almost There!"
        case .overeating:
            return "Over Budget!"
        }
    }
    
    private var progressPercentageText: String {
        if isOvereating {
            let overPercentage = Int((viewModel.progress.eaten / viewModel.progress.target) * 100)
            return "\(overPercentage)%"
        } else {
            return "\(viewModel.progress.progressPercentage)%"
        }
    }
    
    private var progressTextColor: Color {
        if isOvereating {
            return .red
        } else if remainingCalories <= 200 && remainingCalories > 0 {
            return .orange
        } else {
            return .gradientPrimaryText
        }
    }
    
    private var remainingText: String {
        if isOvereating {
            let excess = Int(viewModel.progress.eaten - viewModel.progress.target)
            return "Over by: \(excess) kcal"
        } else {
            return "Remaining: \(viewModel.remainingText)"
        }
    }
    
    private var remainingTextColor: Color {
        if isOvereating {
            return .red
        } else if remainingCalories <= 200 && remainingCalories > 0 {
            return .orange
        } else {
            return .gradientSecondaryText
        }
    }
    
    private var warningIcon: String {
        if isOvereating {
            return "flame.fill"
        } else {
            return "clock.fill"
        }
    }
    
    private var warningColor: Color {
        if isOvereating {
            return .red
        } else {
            return .orange
        }
    }
    
    private var warningMessage: String {
        if isOvereating {
            return "You've exceeded your daily goal"
        } else {
            return "Approaching your daily limit"
        }
    }
}
