//
//  ProteinView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct ProteinView: View {
    let totalProtein: Double
    
    var body: some View {
        Text("Protein: \(totalProtein.asProteinString)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
    }
}
