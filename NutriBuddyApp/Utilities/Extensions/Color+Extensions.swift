//
//  Color+Extensions.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

extension Color {
    // MARK: - System / Standard Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let grayText = Color.gray.opacity(0.6)
    static let whiteText = Color.white

    // MARK: - App Custom Colors
    
    static let customOrange = Color(red: 1.0, green: 0.5, blue: 0.0)
    static let customGreen  = Color(red: 0.0, green: 0.7, blue: 0.3)
    static let customBlue   = Color(red: 0.0, green: 0.5, blue: 1.0)
    static let customPurple = Color(red: 0.6, green: 0.2, blue: 0.8)

    // MARK: - Experimental / Gradients
    static let gradientStart = Color.blue.opacity(0.8)
    static let gradientEnd = Color.purple.opacity(0.6)
}
