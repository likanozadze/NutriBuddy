//
//  BarcodeTabView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import SwiftUI

struct BarcodeTabView: View {
    let onScanTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 64))
                    .foregroundColor(.customOrange)
                
                VStack(spacing: 8) {
                    Text("Scan Barcode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
                    
                    Text("Point your camera at a product barcode to automatically fetch nutritional information")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 12) {
                    Button(action: onScanTapped) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.headline)
                            Text("Start Scanning")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.customOrange)
                        .cornerRadius(12)
                    }
                
                }
                .padding(.horizontal, 48)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
