//
//  NoProfileCard.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 8/24/25.
//

import SwiftUI

struct NoProfileCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(.blue.opacity(0.7))
                
                VStack(spacing: 8) {
                    Text("Set up your profile")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Get personalized calorie and macro targets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                NavigationLink("Create Profile") {
                
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(24)
        }
        .frame(height: 180)
    }
}
