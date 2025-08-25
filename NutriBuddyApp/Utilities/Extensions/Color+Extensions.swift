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
    static let customOrange = Color("CustomOrange")
    static let customBlue = Color("CustomBlue")
    static let customPurple = Color("CustomPurple")
    static let customGreen = Color("CustomGreen")

    // MARK: - Experimental / Gradients
    static let gradientStart = Color.blue.opacity(0.8)
    static let gradientEnd = Color.purple.opacity(0.6)
}
