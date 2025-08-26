//
//  CalorieProgressViewModel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

@MainActor
class CalorieProgressViewModel: ObservableObject {
    @Published private(set) var progress: CalorieProgress
    
    init(progress: CalorieProgress = CalorieProgress(target: 0, eaten: 0, remaining: 0)) {
        self.progress = progress
    }
    
    func updateProgress(_ newProgress: CalorieProgress) {
        progress = newProgress
    }
    
    var formattedDate: String {
        DateFormatter.dateLabel(for: Date())
    }
    
    var targetText: String {
        progress.target.asCalorieString
    }
    
    var eatenText: String {
        progress.eaten.asCalorieString
    }
    var remainingText: String {
            let remaining = max(progress.target - progress.eaten, 0) 
            return remaining.asCalorieString
        }
}
