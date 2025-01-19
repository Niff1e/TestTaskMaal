//
//  CameraViewController.swift
//  TestTaskMaal
//
//  Created by Pavel Maal on 16.01.25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var capturePhotoOutput: AVCapturePhotoOutput!

    var onImageCaptured: ((UIImage) -> Void)?

    // MARK: - Lifecycle of VC

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    // MARK: - Camera setup

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)

        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Камера не доступна.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Ошибка доступа к камере: \(error)")
            return
        }

        capturePhotoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(capturePhotoOutput) {
            captureSession.addOutput(capturePhotoOutput)
        }

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        let captureButton = UIButton(
            frame: CGRect(
                x: (view.frame.size.width - 70) / 2,
                y: view.frame.size.height - 200,
                width: 70,
                height: 70
            )
        )
        captureButton.backgroundColor = .red
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 3
        captureButton.layer.borderColor = UIColor.white.cgColor
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - Photo Handler

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        onImageCaptured?(image)
        dismiss(animated: true)
    }
}
