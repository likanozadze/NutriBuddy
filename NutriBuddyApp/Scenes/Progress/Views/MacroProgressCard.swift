//
//  MacroProgressCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//
//

import SwiftUI

struct MacroProgressCard: View {
    let macro: MacroProgress
    
    var body: some View {
        VStack(spacing: 12) {
            MacroHeaderView(macro: macro)
            MacroCircularProgress(macro: macro)
            MacroDetailsView(macro: macro)
Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(macroCardBackground)
    }
    
    private var macroCardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Macro Card Components
struct MacroHeaderView: View {
    let macro: MacroProgress
    
    var body: some View {
        HStack {
            Circle()
                .fill(macro.color.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: iconName(for: macro.title))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(macro.color)
                )
            
            Spacer()
            
            Text("\(macro.progressPercentage)%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(macro.color)
        }
    }
    
    private func iconName(for title: String) -> String {
        switch title.lowercased() {
        case "protein": return "flame.fill"
        case "carbs": return "leaf.fill"
        case "fats": return "drop.fill"
        case "fiber": return "scissors"
        default: return "circle.fill"
        }
    }
}

struct MacroCircularProgress: View {
    let macro: MacroProgress
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(macro.color.opacity(0.2), lineWidth: 5)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: macro.progress)
                .stroke(macro.color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 50, height: 50)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.8), value: macro.progress)
        
            VStack(spacing: 0) {
                Text("\(Int(macro.current))")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                
                Text(formattedUnit(macro.unit))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formattedUnit(_ unit: String) -> String {
        unit.lowercased() == "k" ? "kcal" : unit
    }
}

struct MacroDetailsView: View {
    let macro: MacroProgress
    
    var body: some View {
        VStack(spacing: 2) {
            Text(macro.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primaryText)
            
            Text("\(macro.current.asGramString)/\(macro.target.asGramString)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}
