//
//  CircularProgressView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let value: Int
    let label: String
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.whiteText.opacity(0.3), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.whiteText, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            VStack(spacing: 2) {
                Text("\(value)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.whiteText)
                
                Text(label)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.whiteText.opacity(0.8))
            }
        }
    }
}
