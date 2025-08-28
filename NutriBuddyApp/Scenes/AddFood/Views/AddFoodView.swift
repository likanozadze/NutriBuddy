//
//  AddFoodView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AddFoodViewModel
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self._viewModel = StateObject(wrappedValue: AddFoodViewModel(selectedDate: selectedDate, context: context))
    }

    let selectedDate: Date
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderCardView()
                    InputCardView(viewModel: viewModel)
                    AdvancedMacrosSection(viewModel: viewModel)
                    PreviewCardView(viewModel: viewModel)
                    SaveButton(isEnabled: viewModel.isValidForm) {
                        viewModel.saveFood()
                        dismiss()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.customBlue)
                }
            }
        }
    }
}

// MARK: - Reusable Save Button
struct SaveButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Save")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? Color.customBlue : Color.secondary.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}

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

// MARK: - Macro Preview Item
struct MacroPreviewItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(8)
    }
}
