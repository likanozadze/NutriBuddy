//
//  CalorieTargetView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct CalorieTargetView: View {
    let target: Double
    let eaten: Double
    let remaining: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Target: \(Int(target)) kcal")
                .font(.headline)
            Text("Eaten: \(eaten.asCalorieString)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Remaining: \(remaining.asCalorieString)")
                .font(.subheadline)
                .foregroundStyle(remaining >= 0 ? .green : .red)
        }
        .padding(.horizontal)
    }
}
