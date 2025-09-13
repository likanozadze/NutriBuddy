//
//  BarcodeResultView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import SwiftUI

struct BarcodeResultView: View {
    let barcodeFood: BarcodeFood
    let onSave: (Double) -> Void
    let onCancel: () -> Void
    
    @State private var grams: String = "100"
    
    private var calculatedCalories: Double {
        guard let gramsValue = Double(grams), gramsValue > 0 else { return 0 }
        return (barcodeFood.caloriesPer100g * gramsValue) / 100
    }
    
    private var calculatedProtein: Double {
        guard let gramsValue = Double(grams), gramsValue > 0 else { return 0 }
        return (barcodeFood.proteinPer100g * gramsValue) / 100
    }
    
    private var calculatedCarbs: Double {
        guard let gramsValue = Double(grams), gramsValue > 0 else { return 0 }
        return (barcodeFood.carbsPer100g * gramsValue) / 100
    }
    
    private var calculatedFat: Double {
        guard let gramsValue = Double(grams), gramsValue > 0 else { return 0 }
        return (barcodeFood.fatPer100g * gramsValue) / 100
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Product Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(barcodeFood.name)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if let brand = barcodeFood.brand {
                                    Text(brand)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Barcode: \(barcodeFood.barcode)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.secondary)
                                )
                        }
                        
                        VStack(spacing: 8) {
                            HStack(spacing: 12) {
                                NutritionBadge(icon: "flame",
                                               value: "\(Int(barcodeFood.caloriesPer100g)) cal/100g",
                                               color: .orange)
                                
                                NutritionBadge(icon: "bolt",
                                               value: "\(Int(barcodeFood.proteinPer100g))g protein/100g",
                                               color: .blue)
                            }
                            
                            if barcodeFood.carbsPer100g > 0 || barcodeFood.fatPer100g > 0 {
                                HStack(spacing: 12) {
                                    if barcodeFood.carbsPer100g > 0 {
                                        NutritionBadge(icon: "leaf",
                                                       value: "\(Int(barcodeFood.carbsPer100g))g carbs/100g",
                                                       color: .green)
                                    }
                                    if barcodeFood.fatPer100g > 0 {
                                        NutritionBadge(icon: "drop",
                                                       value: "\(Int(barcodeFood.fatPer100g))g fat/100g",
                                                       color: .yellow)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // MARK: - Portion Input Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How much did you consume?")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            TextField("100", text: $grams)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                                .frame(width: 100)
                            
                            Text("grams")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    
                    // MARK: - Portion Summary Section
                    if Double(grams) ?? 0 > 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Portion")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 12) {
                                    NutritionValue(title: "Calories",
                                                   value: "\(Int(calculatedCalories))",
                                                   color: .orange)
                                    
                                    NutritionValue(title: "Protein",
                                                   value: "\(Int(calculatedProtein))g",
                                                   color: .blue)
                                }
                                
                                if calculatedCarbs > 0 || calculatedFat > 0 {
                                    HStack(spacing: 12) {
                                        if calculatedCarbs > 0 {
                                            NutritionValue(title: "Carbs",
                                                           value: "\(Int(calculatedCarbs))g",
                                                           color: .green)
                                        }
                                        if calculatedFat > 0 {
                                            NutritionValue(title: "Fat",
                                                           value: "\(Int(calculatedFat))g",
                                                           color: .yellow)
                                        }
                                        if calculatedCarbs == 0 || calculatedFat == 0 { Spacer() }
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Add Barcode Food")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.secondary.opacity(0.2))
                    .foregroundColor(.primary)
                    .cornerRadius(12)
                    
                    Button("Add Food") {
                        guard let gramsValue = Double(grams), gramsValue > 0 else { return }
                        onSave(gramsValue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background((Double(grams) ?? 0) > 0 ? Color.orange : Color.secondary.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled((Double(grams) ?? 0) <= 0)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

