//
//  AddFoodView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI
import SwiftData
import AVFoundation

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddFoodViewModel
    
    let selectedDate: Date
    
    init(selectedDate: Date, context: ModelContext) {
        self.selectedDate = selectedDate
        self._viewModel = StateObject(wrappedValue: AddFoodViewModel(selectedDate: selectedDate, context: context))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabPickerView(selectedTab: $viewModel.selectedTab)
                
                TabView(selection: $viewModel.selectedTab) {
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
                    
                    BarcodeTabView(
                        onScanTapped: {
                            viewModel.handleScanTapped()
                        }
                    )
                    .tag(AddFoodTab.barcode)
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
            .fullScreenCover(isPresented: $viewModel.showingBarcodeScanner) {
                BarcodeScannerView(
                    onBarcodeScanned: { barcode in
                        viewModel.handleBarcodeScanned(barcode)
                    },
                    onCancel: {
                        viewModel.cancelBarcodeScanning()
                    }
                )
            }
            .sheet(isPresented: $viewModel.showingBarcodeResult) {
                if let barcodeFood = viewModel.scannedBarcodeFood {
                    BarcodeResultView(
                        barcodeFood: barcodeFood,
                        onSave: { grams in
                            viewModel.saveBarcodeFood(grams: grams)
                            dismiss()
                        },
                        onCancel: {
                            viewModel.cancelBarcodeResult()
                        }
                    )
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            }
            .overlay {
                if viewModel.isLoadingBarcodeFood {
                    LoadingOverlay(message: viewModel.loadingMessage)
                }
            }
            .alert("Barcode Error", isPresented: $viewModel.showingBarcodeError) {
                Button("OK") {
                    viewModel.dismissBarcodeError()
                }
            } message: {
                if let error = viewModel.barcodeError {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Updated Add Food Tab Enum
enum AddFoodTab: String, CaseIterable {
    case quickAdd = "Quick Add"
    case manual = "Manual"
    case barcode = "Barcode"
    
    var icon: String {
        switch self {
        case .quickAdd: return "clock.arrow.circlepath"
        case .manual: return "plus.circle"
        case .barcode: return "barcode"
        }
    }
}

// MARK: - Loading Overlay
struct LoadingOverlay: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .customOrange))
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.primaryText)
            }
            .padding(24)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Make BarcodeFood Identifiable for Sheet
extension BarcodeFood: Identifiable {
    var id: String { barcode }
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
