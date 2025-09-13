//
//  CameraPreviewView.swift.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import SwiftUI

struct CameraPreviewView: UIViewRepresentable {
    let onBarcodeScanned: (String) -> Void
    
    func makeUIView(context: Context) -> CameraPreview {
        let preview = CameraPreview()
        preview.delegate = context.coordinator
        return preview
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned)
    }
    
    class Coordinator: NSObject, CameraPreviewDelegate {
        let onBarcodeScanned: (String) -> Void
        private var lastScannedCode: String?
        private var lastScanTime: Date = Date()
        private var isProcessing: Bool = false
        
        init(onBarcodeScanned: @escaping (String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }
        
        func didScanBarcode(_ code: String) {
            let now = Date()
            guard !isProcessing else { return }
            
            if lastScannedCode == code && now.timeIntervalSince(lastScanTime) < 3.0 { return }
            
            lastScannedCode = code
            lastScanTime = now
            isProcessing = true
            
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                self.onBarcodeScanned(code)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.isProcessing = false
                }
            }
        }
    }
}
