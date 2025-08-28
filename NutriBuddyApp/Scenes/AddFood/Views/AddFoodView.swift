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
                    headerCard
                    inputCard
                    advancedOptionsToggle
                    if viewModel.showAdvancedOptions {
                        advancedMacrosCard
                    }
                    previewCard
                    
                    Spacer(minLength: 20)
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
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveFood()
                        dismiss()
                    }
                    .disabled(!viewModel.isValidForm)
                    .foregroundColor(viewModel.isValidForm ? .customBlue : .secondary)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private var headerCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.gradientStart, Color.gradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
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
    
    private var inputCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                Text("Food Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Food Name",
                    text: $viewModel.name,
                    icon: "textformat",
                    placeholder: "e.g. Chicken breast"
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("AMOUNT")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                        .textCase(.uppercase)
                    
                    HStack(spacing: 12) {
                        HStack {
                            Image(systemName: viewModel.inputMode.icon)
                                .foregroundColor(.customBlue)
                                .font(.title3)
                            
                            if viewModel.inputMode == .grams {
                                TextField("e.g. 150g", text: $viewModel.grams)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("e.g. 1 serving", text: $viewModel.servingAmount)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .padding(.leading, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Menu {
                            Button(action: { viewModel.inputMode = .grams }) {
                                HStack {
                                    Text("grams")
                                    if viewModel.inputMode == .grams {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            
                            Button(action: { viewModel.inputMode = .servings }) {
                                HStack {
                                    Text("servings")
                                    if viewModel.inputMode == .servings {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.inputMode.displayName.lowercased())
                                    .foregroundColor(.customBlue)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.customBlue)
                                    .font(.caption)
                            }
                            .padding(.trailing, 16)
                        }
                    }
                    .frame(height: 44)
                    .background(Color.listBackground.opacity(0.5))
                    .cornerRadius(8)
                }
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.inputMode == .servings ? "CALORIES" : "CALORIES PER 100G")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                        
                        HStack {
                            Image(systemName: "flame")
                                .foregroundColor(.customOrange)
                                .font(.body)
                            
                            if viewModel.inputMode == .servings {
                                TextField("70", text: $viewModel.servingCalories)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("165", text: $viewModel.caloriesPer100g)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color.listBackground.opacity(0.5))
                        .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.inputMode == .servings ? "PROTEIN (G)" : "PROTEIN PER 100G")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                        
                        HStack {
                            Image(systemName: "bolt")
                                .foregroundColor(.customGreen)
                                .font(.body)
                            
                            if viewModel.inputMode == .servings {
                                TextField("6", text: $viewModel.servingProtein)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            } else {
                                TextField("31", text: $viewModel.proteinPer100g)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                    .foregroundColor(.primaryText)
                            }
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Color.listBackground.opacity(0.5))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var servingInputFields: some View {
        VStack(spacing: 12) {
            CustomTextField(
                title: "Number of Servings",
                text: $viewModel.servingAmount,
                icon: "number.circle",
                placeholder: "e.g. 1",
                keyboardType: .decimalPad
            )
            
            CustomTextField(
                title: "Calories per Serving",
                text: $viewModel.servingCalories,
                icon: "flame",
                placeholder: "e.g. 70",
                keyboardType: .decimalPad
            )
            
            CustomTextField(
                title: "Protein per Serving",
                text: $viewModel.servingProtein,
                icon: "bolt",
                placeholder: "e.g. 6",
                keyboardType: .decimalPad
            )
        }
    }
    
    private var gramsInputFields: some View {
        VStack(spacing: 12) {
            CustomTextField(
                title: "Calories per 100g",
                text: $viewModel.caloriesPer100g,
                icon: "flame",
                placeholder: "e.g. 165",
                keyboardType: .decimalPad
            )
            
            CustomTextField(
                title: "Protein per 100g",
                text: $viewModel.proteinPer100g,
                icon: "bolt",
                placeholder: "e.g. 31",
                keyboardType: .decimalPad
            )
            
            CustomTextField(
                title: "Amount in grams",
                text: $viewModel.grams,
                icon: "scalemass",
                placeholder: "e.g. 150",
                keyboardType: .decimalPad
            )
        }
    }
    
    private var advancedOptionsToggle: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                viewModel.showAdvancedOptions.toggle()
            }
        }) {
            HStack {
                Image(systemName: "chevron.right")
                    .foregroundColor(.customBlue)
                    .rotationEffect(.degrees(viewModel.showAdvancedOptions ? 90 : 0))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.showAdvancedOptions)
                
                Text("Advanced Macros")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Text("Optional")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.cardBackground)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var advancedMacrosCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "chart.pie")
                    .foregroundColor(.customGreen)
                    .font(.title3)
                Text("Additional Macros")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                
                if viewModel.inputMode == .servings {
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: "CARBS/SERVING",
                            text: $viewModel.servingCarbs,
                            icon: "leaf",
                            placeholder: "0.5"
                        )
                        
                        CompactTextField(
                            title: "FAT/SERVING",
                            text: $viewModel.servingFat,
                            icon: "drop",
                            placeholder: "5"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: "FIBER/SERVING",
                            text: $viewModel.servingFiber,
                            icon: "scissors",
                            placeholder: "0"
                        )
                        
                        CompactTextField(
                            title: "SUGAR/SERVING",
                            text: $viewModel.servingSugar,
                            icon: "cube.transparent",
                            placeholder: "0.4"
                        )
                    }
                } else {
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: "CARBS/100G",
                            text: $viewModel.carbsPer100g,
                            icon: "leaf",
                            placeholder: "0"
                        )
                        
                        CompactTextField(
                            title: "FAT/100G",
                            text: $viewModel.fatPer100g,
                            icon: "drop",
                            placeholder: "3.6"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: "FIBER/100G",
                            text: $viewModel.fiberPer100g,
                            icon: "scissors",
                            placeholder: "2.5"
                        )
                        
                        CompactTextField(
                            title: "SUGAR/100G",
                            text: $viewModel.sugarPer100g,
                            icon: "cube.transparent",
                            placeholder: "4.7"
                        )
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }
    
    private var previewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.customBlue)
                    .font(.title3)
                Text("Nutrition Preview")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    MacroPreviewItem(
                        title: "Calories",
                        value: viewModel.calculatedCalories.asCalorieString,
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    MacroPreviewItem(
                        title: "Protein",
                        value: viewModel.calculatedProtein.asProteinString,
                        icon: "bolt.fill",
                        color: .green
                    )
                }
                
                if viewModel.showAdvancedOptions {
                    if viewModel.calculatedCarbs > 0 || viewModel.calculatedFat > 0 {
                        HStack(spacing: 20) {
                            if viewModel.calculatedCarbs > 0 {
                                MacroPreviewItem(
                                    title: "Carbs",
                                    value: viewModel.calculatedCarbs.asProteinString,
                                    icon: "leaf.fill",
                                    color: .blue
                                )
                            }
                            if viewModel.calculatedFat > 0 {
                                MacroPreviewItem(
                                    title: "Fat",
                                    value: viewModel.calculatedFat.asProteinString,
                                    icon: "drop.fill",
                                    color: .purple
                                )
                            }
                        }
                    }
                    
                    if viewModel.calculatedFiber > 0 || viewModel.calculatedSugar > 0 {
                        HStack(spacing: 20) {
                            if viewModel.calculatedFiber > 0 {
                                MacroPreviewItem(
                                    title: "Fiber",
                                    value: viewModel.calculatedFiber.asProteinString,
                                    icon: "scissors",
                                    color: .brown
                                )
                            }
                            if viewModel.calculatedSugar > 0 {
                                MacroPreviewItem(
                                    title: "Sugar",
                                    value: viewModel.calculatedSugar.asProteinString,
                                    icon: "cube.fill",
                                    color: .pink
                                )
                            }
                        }
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
}

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
