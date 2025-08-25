//
//  MacroProgress.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import Foundation
import SwiftUI

struct MacroProgress {
    let title: String
    let current: Double
    let target: Double
    let unit: String
    let color: Color
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    var progressPercentage: Int {
        Int((progress * 100).rounded())
    }
}
