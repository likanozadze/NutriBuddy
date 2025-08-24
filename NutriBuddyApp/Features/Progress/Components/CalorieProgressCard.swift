//
//  CalorieProgressCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct CalorieProgressCard: View {
    let target: Double
    let eaten: Double
    let remaining: Double
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(eaten / target, 1.0)
    }
    
    private var progressPercentage: Int {
        Int((progress * 100).rounded())
    }
    
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
                    
                    Text("\(progressPercentage)%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(dateString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target: \(Int(target)) kcal")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Eaten: \(Int(eaten)) kcal")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                    
                    Text("\(Int(eaten))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Calories")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: 12)
                }
            }
            .padding(20)
        }
      //  .frame(height: 160) 
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: Date())
    }
}


