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
    @State private var selectedTab: AddFoodTab = .quickAdd
    
    let selectedDate: Date
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self._viewModel = StateObject(wrappedValue: AddFoodViewModel(selectedDate: selectedDate, context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabPickerView(selectedTab: $selectedTab)
                
                TabView(selection: $selectedTab) {
                    QuickAddView(
                        viewModel: viewModel,
                        onFoodSelected: { template in
                            viewModel.addQuickFood(template)
                            dismiss()
                        }
                    )
                    .tag(AddFoodTab.quickAdd)
                    
                    ManualAddView(viewModel: viewModel, onSave: {
                        dismiss()
                    })
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
