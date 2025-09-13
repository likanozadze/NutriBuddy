//
//  BarcodeFood.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import Foundation

struct BarcodeFood {
    let barcode: String
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let fiberPer100g: Double
    let sugarPer100g: Double
    let brand: String?
    let imageUrl: String?
    
    init(from product: OpenFoodFactsProduct) {
        self.barcode = product.code ?? ""
        self.name = product.productName ?? "Unknown Product"
        self.brand = product.brands?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageUrl = product.imageFrontUrl
        
        let nutriments = product.nutriments
        if let energyKcal = nutriments?.energyKcal100g, energyKcal > 0 {
            self.caloriesPer100g = energyKcal
        } else if let energyKj = nutriments?.energy100g, energyKj > 0 {
            self.caloriesPer100g = energyKj / 4.184
        } else {
            self.caloriesPer100g = 0
        }
        
        self.proteinPer100g = nutriments?.proteins100g ?? 0
        self.carbsPer100g = nutriments?.carbohydrates100g ?? 0
        self.fatPer100g = nutriments?.fat100g ?? 0
        self.fiberPer100g = nutriments?.fiber100g ?? 0
        self.sugarPer100g = nutriments?.sugars100g ?? 0
    }
}
