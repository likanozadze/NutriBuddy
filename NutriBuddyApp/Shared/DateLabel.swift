//
//  DateLabel.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct DateLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primaryText)
    }
}
