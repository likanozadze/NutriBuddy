//
//  CameraPreview.swift
//  NutriBuddyApp
//
//  Created by Lika Nozadze on 9/13/25.
//

import UIKit
import AVFoundation

protocol CameraPreviewDelegate: AnyObject {
    func didScanBarcode(_ code: String)
}

class CameraPreview: UIView {
    weak var delegate: CameraPreviewDelegate?
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCamera()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            failed()
            return
        }
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(metadataOutput) else {
            failed()
            return
        }
        captureSession.addOutput(metadataOutput)
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [
            .ean8, .ean13, .pdf417, .qr, .code128, .code39, .code93,
            .upce, .aztec, .dataMatrix, .interleaved2of5, .itf14
        ]
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = layer.bounds
    }
    
    private func failed() {
        let ac = UIAlertController(
            title: "Scanning not supported",
            message: "Your device does not support barcode scanning.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(ac, animated: true)
        }
        captureSession = nil
    }
    
    func startScanning() {
        if !captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
            }
        }
    }
    
    func stopScanning() {
        if captureSession.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.stopRunning()
            }
        }
    }
}

extension CameraPreview: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            delegate?.didScanBarcode(stringValue)
        }
    }
}
