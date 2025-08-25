//
//  NoProfileCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//


import SwiftUI

struct NoProfileCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.secondaryText.opacity(0.6))
            
            Text("No Profile Found")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            Text("Create a profile to track your nutrition goals")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
