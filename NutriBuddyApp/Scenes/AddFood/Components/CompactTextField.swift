//
//  CompactTextField.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/29/25.
//

import SwiftUI

// MARK: - Compact TextField
struct CompactTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondaryText)
                .textCase(.uppercase)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.customBlue)
                    .font(.body)
                
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .font(.body)
                    .foregroundColor(.primaryText)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color.listBackground.opacity(0.5))
            .cornerRadius(8)
        }
    }
}
