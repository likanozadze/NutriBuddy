//
//  NutritionInfo.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/27/25.
//

import SwiftUI

// MARK: - Data Models
struct NutritionInfo {
    let label: String
    let value: Int
    let baseValue: Int
    let unit: String?
    let color: LinearGradient
    let icon: String
}

// MARK: - Uniform Nutrition Grid
struct UniformNutritionGrid: View {
    let nutritionData: [NutritionInfo]
    let showBaseValues: Bool
    let isAnimating: Bool
    
    init(nutritionData: [NutritionInfo], showBaseValues: Bool, isAnimating: Bool = false) {
        self.nutritionData = nutritionData
        self.showBaseValues = showBaseValues
        self.isAnimating = isAnimating
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
            ForEach(nutritionData, id: \.label) { item in
                UniformNutritionCard(
                    info: item,
                    showBaseValue: showBaseValues,
                    isAnimating: isAnimating
                )
            }
        }
    }
}

// MARK: - Uniform Nutrition Card
struct UniformNutritionCard: View {
    let info: NutritionInfo
    let showBaseValue: Bool
    let isAnimating: Bool
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: info.icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(info.color)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(info.label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)

                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(showBaseValue ? info.baseValue : info.value)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)

                if let unit = info.unit {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(cardBorder, lineWidth: 1)
                )
        )
    }

    private var cardBackground: some ShapeStyle {
        if colorScheme == .dark {
            return AnyShapeStyle(Color(.systemGray5))
        } else {
            return AnyShapeStyle(Color(.systemGray6).opacity(0.3))
        }
    }

    private var cardBorder: Color {
        colorScheme == .dark ? Color(.systemGray4) : Color.white.opacity(0.2)
    }
}

// MARK: - Nutrition Value Component
struct NutritionValue: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.5))
        .cornerRadius(8)
    }
}


