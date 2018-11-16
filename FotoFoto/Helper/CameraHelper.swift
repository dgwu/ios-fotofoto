//
//  CameraHelper.swift
//  FotoFoto
//
//  Created by Daniel Gunawan on 16/11/18.
//  Copyright © 2018 Daniel Gunawan. All rights reserved.
//

import AVFoundation
import UIKit

class CameraHelper {
    
    var captureSession: AVCaptureSession?
    var videoOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var activeInput: AVCaptureDeviceInput?
    var outputURL: URL?
    var outputDelegate: AVCaptureFileOutputRecordingDelegate
    
    init(outputDelegate: AVCaptureFileOutputRecordingDelegate) {
        self.outputDelegate = outputDelegate
    }
    
    func setupSession() -> Bool {
        // create the session
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {return false}
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // set up the camera
        guard let camera = AVCaptureDevice.default(for: .video) else {return false}
        do {
            let cameraInput =  try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                activeInput = cameraInput
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        //        // set up the mic
        //        guard let mic = AVCaptureDevice.default(for: .audio) else {return false}
        //        do {
        //            let micInput = try AVCaptureDeviceInput(device: mic)
        //            if captureSession.canAddInput(micInput) {
        //                captureSession.addInput(micInput)
        //            }
        //        } catch {
        //            print("Error setting device video input: \(error)")
        //            return false
        //        }
        
        // video output
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        return true
    }
    
    func startSession() {
        guard let sessionIsRunning = captureSession?.isRunning else {return}
        if !sessionIsRunning {
            DispatchQueue.main.async {
                self.captureSession?.startRunning()
            }
        }
    }
    
    func stopSession() {
        guard let sessionIsRunning = captureSession?.isRunning else {return}
        if sessionIsRunning {
            DispatchQueue.main.async {
                self.captureSession?.stopRunning()
            }
        }
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func startRecording() {
        if videoOutput.isRecording == false {
            
            let connection = videoOutput.connection(with: .video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            guard let activeInput = activeInput else {return}
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            outputURL = tempURL()
            guard let outputURL = outputURL else {return}
            videoOutput.startRecording(to: outputURL, recordingDelegate: outputDelegate)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if videoOutput.isRecording == true {
            videoOutput.stopRecording()
        }
    }
    
}


