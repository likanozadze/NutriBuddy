//
//  StepProgressRing.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/28/25.
//

import SwiftUI

struct StepProgressRing: View {
    var steps: Int
    var goal: Int
    var ringColor: Color = .customBlue
    
    @State private var animatedSteps: Int = 0
    
    var progress: Double {
        min(Double(animatedSteps) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: progress)
                
                VStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(ringColor)
                        .font(.title2)
                    Text("\(animatedSteps.formatted())")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    Text("/ \(goal.formatted())")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
            .frame(width: 80, height: 80)
            
            Text("Steps")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .onAppear {
            animatedSteps = 0
            let stepIncrement = max(1, steps / 50)
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
                if animatedSteps < steps {
                    animatedSteps += stepIncrement
                } else {
                    animatedSteps = steps
                    timer.invalidate()
                }
            }
        }
        
    }
}

