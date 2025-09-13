//
//  BarcodeFoodService.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import Foundation

class BarcodeFoodService: ObservableObject {
    private let session = URLSession.shared
    
    func fetchFoodInfo(barcode: String) async -> BarcodeFood? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json") else { return nil }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else { return nil }
            
            let result = try JSONDecoder().decode(OpenFoodFactsResponse.self, from: data)
            if result.status == 1, let product = result.product {
                return BarcodeFood(from: product)
            } else {
                return nil
            }
        } catch {
            print("Error fetching barcode data: \(error)")
            return nil
        }
    }
}

extension BarcodeFoodService {
    func testBarillaLookup() async {
        let testBarcodes = ["8076809513821", "8076809513838", "3017620422003"]
        for barcode in testBarcodes {
            let result = await fetchFoodInfo(barcode: barcode)
            print(result?.name ?? "Not found")
        }
    }
}
