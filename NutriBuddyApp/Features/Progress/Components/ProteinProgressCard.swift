//
//  ProteinProgressCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct ProteinProgressCard: View {
    let current: Double
    let target: Double
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(current / target, 1.0)
    }
    
    var body: some View {
        MacroProgressCard(
            title: "Protein",
            current: current,
            target: target,
            unit: "g",
            color: .green
        )
    }
}
