//
//  FoodSearchService.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/11/25.
//

import Foundation

class FoodSearchService {
    private let baseURL = "https://api.nal.usda.gov/fdc/v1"
    
    private var apiKey: String {
           guard let key = Bundle.main.infoDictionary?["FDC_API_KEY"] as? String else {
               fatalError("❌ Missing FDC_API_KEY in .xcconfig or Info.plist")
           }
           return key
       }
    func searchFoods(query: String) async -> [APIFood] {
        guard !query.isEmpty else { return [] }
        guard var urlComponents = URLComponents(string: "\(baseURL)/foods/search") else { return [] }

        urlComponents.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "dataType", value: "Foundation,SR Legacy,Branded"),
            URLQueryItem(name: "pageSize", value: "10"),
            URLQueryItem(name: "pageNumber", value: "1"),
            URLQueryItem(name: "sortBy", value: "dataType.keyword"),
            URLQueryItem(name: "sortOrder", value: "asc")
        ]

        guard let url = urlComponents.url else { return [] }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Server error - Status code: \(httpResponse.statusCode)")
                return []
            }

            let searchResponse = try JSONDecoder().decode(FoodSearchResponse.self, from: data)
            return searchResponse.foods

        } catch {
            print("Error fetching foods: \(error)")
            return []
        }
    }
}
