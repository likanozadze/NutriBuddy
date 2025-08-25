//
//  NavigationDirection.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

enum NavigationDirection {
    case previous, next
    
    var systemName: String {
        switch self {
        case .previous: return "chevron.left"
        case .next: return "chevron.right"
        }
    }
}

struct NavigationButton: View {
    let direction: NavigationDirection
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: direction.systemName)
                .font(.title3)
                .foregroundColor(.primaryText)
        }
    }
}
