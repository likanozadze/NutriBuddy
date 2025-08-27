//
//  Double+Formatting.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import Foundation

extension Double {
    var asCalorieString: String {
        "\(Int(self)) kcal"
    }
    
    var asProteinString: String {
        String(format: "%.1f g protein", self)
    }
    
    var asGramString: String {
        "\(Int(self)) g"
    }
}
