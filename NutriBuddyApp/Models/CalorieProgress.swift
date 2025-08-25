//
//  CalorieProgress.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import Foundation
import SwiftUI

struct CalorieProgress {
    let target: Double
    let eaten: Double
    let remaining: Double
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(eaten / target, 1.0)
    }
    
    var progressPercentage: Int {
        Int((progress * 100).rounded())
    }
}
