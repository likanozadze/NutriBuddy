//
//  OpenFoodFactsModels.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import Foundation

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: OpenFoodFactsProduct?
    let statusVerbose: String?
    
    enum CodingKeys: String, CodingKey {
        case status, product
        case statusVerbose = "status_verbose"
    }
}

struct OpenFoodFactsProduct: Codable {
    let code: String?
    let productName: String?
    let productNameEn: String?
    let brands: String?
    let nutriments: Nutriments?
    let imageFrontUrl: String?
    let imageFrontSmallUrl: String?
    let servingSize: String?
    let servingQuantity: Double?
    let quantity: String?
    let productQuantity: Double?
    
    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case productNameEn = "product_name_en"
        case brands, nutriments
        case imageFrontUrl = "image_front_url"
        case imageFrontSmallUrl = "image_front_small_url"
        case servingSize = "serving_size"
        case servingQuantity = "serving_quantity"
        case quantity
        case productQuantity = "product_quantity"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try container.decodeIfPresent(String.self, forKey: .code)
        productName = try container.decodeIfPresent(String.self, forKey: .productName)
        productNameEn = try container.decodeIfPresent(String.self, forKey: .productNameEn)
        brands = try container.decodeIfPresent(String.self, forKey: .brands)
        nutriments = try container.decodeIfPresent(Nutriments.self, forKey: .nutriments)
        imageFrontUrl = try container.decodeIfPresent(String.self, forKey: .imageFrontUrl)
        imageFrontSmallUrl = try container.decodeIfPresent(String.self, forKey: .imageFrontSmallUrl)
        servingSize = try container.decodeIfPresent(String.self, forKey: .servingSize)
        quantity = try container.decodeIfPresent(String.self, forKey: .quantity)
        
   
        if let servingQuantityDouble = try? container.decodeIfPresent(Double.self, forKey: .servingQuantity) {
            servingQuantity = servingQuantityDouble
        } else if let servingQuantityString = try? container.decodeIfPresent(String.self, forKey: .servingQuantity) {
            servingQuantity = Double(servingQuantityString)
        } else {
            servingQuantity = nil
        }
        
       
        if let productQuantityDouble = try? container.decodeIfPresent(Double.self, forKey: .productQuantity) {
            productQuantity = productQuantityDouble
        } else if let productQuantityString = try? container.decodeIfPresent(String.self, forKey: .productQuantity) {
            productQuantity = Double(productQuantityString)
        } else {
            productQuantity = nil
        }
    }
}

struct Nutriments: Codable {
    let energy100g: Double?
    let energyKcal100g: Double?
    let proteins100g: Double?
    let carbohydrates100g: Double?
    let fat100g: Double?
    let fiber100g: Double?
    let sugars100g: Double?
    let salt100g: Double?
    let sodium100g: Double?
    
    enum CodingKeys: String, CodingKey {
        case energy100g = "energy_100g"
        case energyKcal100g = "energy-kcal_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
        case fiber100g = "fiber_100g"
        case sugars100g = "sugars_100g"
        case salt100g = "salt_100g"
        case sodium100g = "sodium_100g"
    }
}
