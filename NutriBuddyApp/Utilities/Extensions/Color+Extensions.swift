//
//  Color+Extensions.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/25/25.
//

import SwiftUI

extension Color {
    // MARK: - Simple Adaptive Backgrounds
    static let appBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    })
    
    static let cardBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            : UIColor.white 
    })
    
    static let listBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    })
    
    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
 
    
    // MARK: - Gradient Text Colors
    static let gradientPrimaryText = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white
            : UIColor.white
    })
    
    static let gradientSecondaryText = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.9)
            : UIColor.white.withAlphaComponent(0.9)
    })
    
    static let gradientTertiaryText = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.8)
            : UIColor.white.withAlphaComponent(0.8)
    })
    
    // MARK: - Your Original Colors (Enhanced for Dark Mode)
    static let customOrange = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)
            : UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    })
    
    static let customGreen = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 1.0)
            : UIColor(red: 0.0, green: 0.7, blue: 0.3, alpha: 1.0)
    })
    
    static let customBlue = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
            : UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    })
    
    // MARK: - Simple Gradients
    static let gradientStart = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0)
            : UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    })
    
    static let gradientEnd = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 1.0)
            : UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 1.0) 
    })
}

// MARK: - Simple View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(12)
    }
    
    func listItemStyle() -> some View {
        self
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(8)
    }
}

extension Color {
    static let calorieCardButtonBlue = Color.gradientStart
}

