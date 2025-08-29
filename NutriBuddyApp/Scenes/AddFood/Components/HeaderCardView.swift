//
//  HeaderCardView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/28/25.
//

import SwiftUI

struct HeaderCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Add New Food")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text("Track your nutrition by adding food details")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}
