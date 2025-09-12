//
//  FoodLogHeaderCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/11/25.
//

import SwiftUI

struct FoodLogHeaderCard: View {
    var foodCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Food Log")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                Spacer()
                Text("\(foodCount) item\(foodCount == 1 ? "" : "s") logged")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.cardBackground)
        )
        
    }
}
