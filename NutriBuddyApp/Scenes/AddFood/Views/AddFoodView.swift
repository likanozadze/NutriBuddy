//
//  AddFoodView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//
//
//import SwiftUI
//import SwiftData
//
//struct AddFoodView: View {
//    @Environment(\.modelContext) private var context
//    @Environment(\.dismiss) private var dismiss
//    
//    @StateObject private var viewModel: AddFoodViewModel
//    
//    init(selectedDate: Date, context: ModelContext) {
//        self.selectedDate = selectedDate
//        self._viewModel = StateObject(wrappedValue: AddFoodViewModel(selectedDate: selectedDate, context: context))
//    }
//
//    let selectedDate: Date
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 20) {
//                    HeaderCardView()
//                    InputCardView(viewModel: viewModel)
//                    AdvancedMacrosSection(viewModel: viewModel)
//                    PreviewCardView(viewModel: viewModel)
//                    SaveButton(isEnabled: viewModel.isValidForm) {
//                        viewModel.saveFood()
//                        dismiss()
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 8)
//            }
//            .background(Color.appBackground)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItemGroup(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                    .foregroundColor(.customBlue)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Reusable Save Button
//struct SaveButton: View {
//    let isEnabled: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            Text("Save")
//                .fontWeight(.semibold)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(isEnabled ? Color.customBlue : Color.secondary.opacity(0.3))
//                .foregroundColor(.white)
//                .cornerRadius(12)
//        }
//        .disabled(!isEnabled)
//    }
//}
//
//// MARK: - Compact TextField
//struct CompactTextField: View {
//    let title: String
//    @Binding var text: String
//    let icon: String
//    let placeholder: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(title)
//                .font(.caption2)
//                .foregroundColor(.secondaryText)
//                .textCase(.uppercase)
//            
//            HStack {
//                Image(systemName: icon)
//                    .foregroundColor(.customBlue)
//                    .font(.body)
//                
//                TextField(placeholder, text: $text)
//                    .keyboardType(.decimalPad)
//                    .font(.body)
//                    .foregroundColor(.primaryText)
//            }
//            .padding(.horizontal, 12)
//            .frame(height: 40)
//            .background(Color.listBackground.opacity(0.5))
//            .cornerRadius(8)
//        }
//    }
//}
//
//// MARK: - Macro Preview Item
//struct MacroPreviewItem: View {
//    let title: String
//    let value: String
//    let icon: String
//    let color: Color
//    
//    var body: some View {
//        VStack(spacing: 8) {
//            Image(systemName: icon)
//                .font(.title2)
//                .foregroundColor(color)
//            
//            Text(value)
//                .font(.title3)
//                .fontWeight(.bold)
//                .foregroundColor(.primaryText)
//            
//            Text(title)
//                .font(.caption)
//                .foregroundColor(.secondaryText)
//                .textCase(.uppercase)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 16)
//        .background(Color.listBackground.opacity(0.5))
//        .cornerRadius(8)
//    }
//}
import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: AddFoodViewModel
    @State private var selectedTab: AddFoodTab = .quickAdd
    

    @Query private var allFoods: [FoodEntry]
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self._viewModel = StateObject(wrappedValue: AddFoodViewModel(selectedDate: selectedDate, context: context))
    }

    let selectedDate: Date
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
               
                TabPickerView(selectedTab: $selectedTab)
                
                TabView(selection: $selectedTab) {
                    QuickAddView(
                        uniqueFoods: uniqueFoodTemplates,
                        onFoodSelected: { template in
                            addQuickFood(template)
                        }
                    )
                    .tag(AddFoodTab.quickAdd)
                    
                    ManualAddView(viewModel: viewModel)
                        .tag(AddFoodTab.manual)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
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
    
    private var uniqueFoodTemplates: [FoodTemplate] {
        let grouped = Dictionary(grouping: allFoods) { food in
            "\(food.name)-\(food.caloriesPer100g)-\(food.proteinPer100g)-\(food.carbsPer100g)-\(food.fatPer100g)"
        }
        
        return grouped.compactMap { _, foods in
            guard let first = foods.first else { return nil }
            
            let totalEntries = foods.count
            let lastUsed = foods.max(by: { $0.date < $1.date })?.date ?? Date.distantPast
            
            return FoodTemplate(
                name: first.name,
                caloriesPer100g: first.caloriesPer100g,
                proteinPer100g: first.proteinPer100g,
                carbsPer100g: first.carbsPer100g,
                fatPer100g: first.fatPer100g,
                fiberPer100g: first.fiberPer100g,
                sugarPer100g: first.sugarPer100g,
                inputMode: first.inputMode,
                servingSize: first.servingSize,
                timesUsed: totalEntries,
                lastUsed: lastUsed
            )
        }
        .sorted { $0.lastUsed > $1.lastUsed }
    }
    
    private func addQuickFood(_ template: FoodTemplate) {
        let food = FoodEntry(
            name: template.name,
            caloriesPer100g: template.caloriesPer100g,
            proteinPer100g: template.proteinPer100g,
            carbsPer100g: template.carbsPer100g,
            fatPer100g: template.fatPer100g,
            fiberPer100g: template.fiberPer100g,
            sugarPer100g: template.sugarPer100g,
            grams: template.servingSize ?? 100,
            date: selectedDate,
            inputMode: template.inputMode,
            servingSize: template.servingSize
        )
        
        context.insert(food)
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save quick food: \(error)")
        }
    }
}

// MARK: - Food Template Model
struct FoodTemplate: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let inputMode: String
    let servingSize: Double?
    let timesUsed: Int
    let lastUsed: Date
    
    var isServingMode: Bool {
        inputMode == "servings"
    }
}

// MARK: - Add Food Tab Enum
enum AddFoodTab: String, CaseIterable {
    case quickAdd = "Quick Add"
    case manual = "Manual"
    
    var icon: String {
        switch self {
        case .quickAdd: return "clock.arrow.circlepath"
        case .manual: return "plus.circle"
        }
    }
}

// MARK: - Tab Picker View
struct TabPickerView: View {
    @Binding var selectedTab: AddFoodTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AddFoodTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(tab.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(selectedTab == tab ? .customOrange : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Quick Add View
struct QuickAddView: View {
    let uniqueFoods: [FoodTemplate]
    let onFoodSelected: (FoodTemplate) -> Void
    @State private var searchText = ""
    
    var filteredFoods: [FoodTemplate] {
        if searchText.isEmpty {
            return uniqueFoods
        }
        return uniqueFoods.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if uniqueFoods.isEmpty {
                EmptyQuickAddView()
            } else {
                VStack(spacing: 12) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search foods...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.listBackground.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    
                    // Foods List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredFoods) { template in
                                QuickAddFoodCard(
                                    template: template,
                                    onTap: {
                                        onFoodSelected(template)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
        .background(Color.appBackground)
    }
}

// MARK: - Quick Add Food Card
struct QuickAddFoodCard: View {
    let template: FoodTemplate
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    HStack(spacing: 16) {
                        NutritionBadge(
                            icon: "flame",
                            value: "\(Int(template.caloriesPer100g)) cal",
                            color: .customOrange
                        )
                        
                        NutritionBadge(
                            icon: "bolt",
                            value: "\(Int(template.proteinPer100g))g protein",
                            color: .customBlue
                        )
                    }
                    
                    HStack(spacing: 8) {
                        Text("Used \(template.timesUsed) times")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if template.isServingMode {
                            Text("• Serving mode")
                                .font(.caption)
                                .foregroundColor(.customOrange)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.customOrange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nutrition Badge
struct NutritionBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
    }
}

// MARK: - Empty Quick Add View
struct EmptyQuickAddView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundColor(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Previous Foods")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Text("Add some foods manually first, then they'll appear here for quick adding")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Manual Add View
struct ManualAddView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
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
    }
}

// MARK: - Existing Components

struct AddInputCardView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.customOrange)
                    .font(.title3)
                
                Text("Food Details")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                CompactTextField(
                    title: "Food Name",
                    text: $viewModel.name,
                    icon: "textformat.abc",
                    placeholder: "e.g. Chicken breast"
                )
                
                HStack(spacing: 12) {
                    CompactTextField(
                        title: "Amount",
                        text: viewModel.inputMode == .servings ? $viewModel.servingAmount : $viewModel.grams,
                        icon: viewModel.inputMode.icon,
                        placeholder: viewModel.inputMode == .servings ? "1.0" : "150"
                    )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Unit")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                            .textCase(.uppercase)
                        
                        Menu {
                            ForEach(NutritionInputMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    viewModel.inputMode = mode
                                }) {
                                    HStack {
                                        Image(systemName: mode.icon)
                                        Text(mode.displayName)
                                        if viewModel.inputMode == mode {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: viewModel.inputMode.icon)
                                    .foregroundColor(.customBlue)
                                
                                Text(viewModel.inputMode.displayName)
                                    .foregroundColor(.primaryText)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 40)
                            .background(Color.listBackground.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    CompactTextField(
                        title: viewModel.inputMode == .servings ? "Calories per serving" : "Calories per 100g",
                        text: viewModel.inputMode == .servings ? $viewModel.servingCalories : $viewModel.caloriesPer100g,
                        icon: "flame",
                        placeholder: "165"
                    )
                    
                    CompactTextField(
                        title: viewModel.inputMode == .servings ? "Protein per serving" : "Protein per 100g",
                        text: viewModel.inputMode == .servings ? $viewModel.servingProtein : $viewModel.proteinPer100g,
                        icon: "bolt",
                        placeholder: "31"
                    )
                }
            }
        }
        .padding(16)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(16)
    }
}

struct AddAdvancedMacrosSection: View {
    @ObservedObject var viewModel: AddFoodViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.showAdvancedOptions.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(viewModel.showAdvancedOptions ? 90 : 0))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.showAdvancedOptions)
                    
                    Text("Advanced Macros")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("Optional")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
                .foregroundColor(.primaryText)
            }
            .buttonStyle(.plain)
            
            if viewModel.showAdvancedOptions {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: viewModel.inputMode == .servings ? "Carbs per serving" : "Carbs per 100g",
                            text: viewModel.inputMode == .servings ? $viewModel.servingCarbs : $viewModel.carbsPer100g,
                            icon: "leaf",
                            placeholder: "0"
                        )
                        
                        CompactTextField(
                            title: viewModel.inputMode == .servings ? "Fat per serving" : "Fat per 100g",
                            text: viewModel.inputMode == .servings ? $viewModel.servingFat : $viewModel.fatPer100g,
                            icon: "drop",
                            placeholder: "3.6"
                        )
                    }
                    
                    HStack(spacing: 12) {
                        CompactTextField(
                            title: viewModel.inputMode == .servings ? "Fiber per serving" : "Fiber per 100g",
                            text: viewModel.inputMode == .servings ? $viewModel.servingFiber : $viewModel.fiberPer100g,
                            icon: "leaf.circle",
                            placeholder: "0"
                        )
                        
                        CompactTextField(
                            title: viewModel.inputMode == .servings ? "Sugar per serving" : "Sugar per 100g",
                            text: viewModel.inputMode == .servings ? $viewModel.servingSugar : $viewModel.sugarPer100g,
                            icon: "cube",
                            placeholder: "0"
                        )
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(16)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(16)
    }
}

struct AddPreviewCardView: View {
    @ObservedObject var viewModel: AddFoodViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.customBlue)
                    .font(.title3)
                
                Text("Nutrition Preview")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                MacroPreviewItem(
                    title: "Calories",
                    value: "\(Int(viewModel.calculatedCalories)) kcal",
                    icon: "flame",
                    color: .customOrange
                )
                
                MacroPreviewItem(
                    title: "Protein",
                    value: "\(viewModel.calculatedProtein.asProteinString)",
                    icon: "bolt",
                    color: .customBlue
                )
            }
        }
        .padding(16)
        .background(Color.listBackground.opacity(0.5))
        .cornerRadius(16)
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

// MARK: - Extensions for formatting
extension Double {
    var AddasProteinString: String {
        return String(format: "%.1fg", self)
    }
}
