//
//  FoodSearchResponse.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/10/25.
//
import Foundation

// MARK: - API Response Models
struct FoodSearchResponse: Codable {
    let foods: [APIFood]
    let totalHits: Int?
    let currentPage: Int?
    let totalPages: Int?
}
