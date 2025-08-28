//
//  CustomTextField.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/26/25.
//

import SwiftUI
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 4 : 6) {
            if !compact {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondaryText)
                    .textCase(.uppercase)
            }

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.customBlue)
                    .frame(width: 20)
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(.primaryText)
            }
            .padding(.vertical, compact ? 8 : 12)
            .padding(.horizontal, compact ? 12 : 16)
            .background(Color.listBackground)
            .cornerRadius(8)
        }
    }
}
