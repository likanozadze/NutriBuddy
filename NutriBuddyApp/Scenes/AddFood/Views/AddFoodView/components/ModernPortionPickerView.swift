//
//  ModernPortionPickerView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/27/25.
//

import SwiftUI

// MARK: - Modern Portion Picker
struct ModernPortionPickerView: View {
    @Binding var selectedPortion: PortionType
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
     
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(PortionType.allCases.filter { $0 != .custom }, id: \.self) { portion in
                            PortionRowView(
                                portion: portion,
                                isSelected: selectedPortion == portion,
                                onTap: {
                                    selectedPortion = portion
                                    onDismiss()
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Portion Row View
struct PortionRowView: View {
    let portion: PortionType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(portion.emoji)
                    .font(.title2)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(portion.displayName)
                        .font(.body)
                        .fontWeight(isSelected ? .semibold : .regular)
                        .foregroundColor(isSelected ? .blue : .primary)

                    if portion != .custom {
                        Text("≈ \(Int(portion.gramsEquivalent(for: APIFood(fdcId: 0, description: "", foodNutrients: [], dataType: nil, commonNames: nil, additionalDescriptions: nil))))g")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Enter grams manually")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}


