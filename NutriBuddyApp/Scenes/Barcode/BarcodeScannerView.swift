//
//  BarcodeScannerView.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import SwiftUI

struct BarcodeScannerView: View {
    let onBarcodeScanned: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                CameraPreviewView(onBarcodeScanned: onBarcodeScanned)
                
                VStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.customOrange, lineWidth: 3)
                        .frame(width: 280, height: 180)
                        .overlay(BarcodeFrameOverlay())
                    
                    Text("Position barcode within the frame")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

private struct BarcodeFrameOverlay: View {
    var body: some View {
        VStack {
            HStack {
                Rectangle().fill(Color.customOrange).frame(width: 20, height: 3).cornerRadius(1.5)
                Spacer()
                Rectangle().fill(Color.customOrange).frame(width: 20, height: 3).cornerRadius(1.5)
            }
            Spacer()
            HStack {
                Rectangle().fill(Color.customOrange).frame(width: 20, height: 3).cornerRadius(1.5)
                Spacer()
                Rectangle().fill(Color.customOrange).frame(width: 20, height: 3).cornerRadius(1.5)
            }
        }
        .padding(8)
    }
}
