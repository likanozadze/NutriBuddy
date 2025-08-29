//
//  CircularProgressView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//
//
import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let value: Int
    let label: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gradientSecondaryText.opacity(0.3), lineWidth: 8)
                .frame(width: 90, height: 90)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.gradientPrimaryText, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 90, height: 90)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.gradientPrimaryText)
                
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gradientTertiaryText)
            }
        }
    }
}
