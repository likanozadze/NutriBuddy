//
//  NutriBuddyAppApp.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/23/25.
//

import SwiftUI

@main
struct NutriBuddyAppApp: App {
    var body: some Scene {
        WindowGroup {
            FoodListView()
        }
        .modelContainer(for: FoodEntry.self)
    }
}
