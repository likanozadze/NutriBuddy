//
//  MacroProgressCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//
import SwiftUI

struct MacroProgressCard: View {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    private var progressPercentage: Int {
        Int((progress * 100).rounded())
    }
    
    var body: some View {
        VStack(spacing: 12) {
           
            HStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(color)
                    )
                
                Spacer()
                
                Text("\(progressPercentage)%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 5)
                    .frame(width: 50, height: 50)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: progress)
            
                VStack(spacing: 0) {
                    Text("\(Int(current))")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(unit.lowercased() == "k" ? "kcal" : unit)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }
           
            }
            

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("\(Int(current))/\(Int(target)) \(unit.lowercased() == "k" ? "kcal" : unit)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    private var iconName: String {
        switch title.lowercased() {
        case "protein": return "flame.fill"
        case "carbs": return "leaf.fill"
        case "fats": return "drop.fill"
        case "fiber": return "scissors"
        default: return "circle.fill"
        }
    }
}
