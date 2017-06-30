//
//  BaseViewController.swift
//  ULC
//
//  Created by Alexey on 6/9/16.
//  Copyright © 2016 wezom.com.ua. All rights reserved.
//

import UIKit
import AVFoundation
import ReactiveCocoa
import Result

class BaseViewController: UIViewController {
    
    let loginViewModel: Logining = LoginViewModel();
    
    // MARK private properties
    private let session = AVCaptureSession()
    private let availableCameraDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
    private var frontCameraDevice: AVCaptureDevice?;
    
    func racTextProducer(textField: UITextField, throttleValue: Double = 0.5) -> SignalProducer<String?, NoError> {
        return textField
            .rac_textSignal()
            .toSignalProducer()
            .flatMapError({ error in return SignalProducer<AnyObject?, NoError>.empty })
            .map({ text in (text as? String)! })
            .throttle(throttleValue, onScheduler: QueueScheduler.mainQueueScheduler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        checkApiVersion();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        session.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        session.stopRunning();
    }
    
    func cameraWithBlurEffect(topCoverImageView: UIImageView, bottomCoverImageView: UIImageView) {
        
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        switch authorizationStatus {
            
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo,
                                                      completionHandler: { [weak self](granted: Bool) -> Void in
                                                        if granted {
                                                            dispatch_after(0, dispatch_get_main_queue()) { _ in
                                                                self?.checkCamera(topCoverImageView, bottomCoverImageView: bottomCoverImageView);
                                                            }
                                                        }
                                                        else {
                                                            self?.configureDeniedAccess(topCoverImageView);
                                                        }
                })
        case .Authorized:
            checkCamera(topCoverImageView, bottomCoverImageView: bottomCoverImageView);
            break
            
        case .Denied, .Restricted:
            configureDeniedAccess(topCoverImageView)
            break
        }
    }
    
    private func configureDeniedAccess(topCoverImageView: UIImageView) {
        dispatch_after(0, dispatch_get_main_queue()) {
            topCoverImageView.image = R.image.login_background_image()
        }
    }
    
    private func checkCamera(topCoverImageView: UIImageView, bottomCoverImageView: UIImageView) {
        
        assert(NSThread.isMainThread(), "Init layer's camera must be in UI thread")
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        for device in availableCameraDevices as! [AVCaptureDevice] {
            
            if device.position == .Front {
                frontCameraDevice = device
            }
        }
        
        guard let currentCamera = frontCameraDevice else {
            return;
        }
        
        do {
            let possibleCameraInput = try AVCaptureDeviceInput.init(device: currentCamera)
            if session.canAddInput(possibleCameraInput) {
                session.addInput(possibleCameraInput);
                let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.frame = self.view.bounds
                bottomCoverImageView.image = nil
                bottomCoverImageView.layer.addSublayer(previewLayer);
                session.startRunning();
                addBlurEffect(bottomCoverImageView)
            }
        } catch {
            configureDeniedAccess(topCoverImageView);
        }
    }
    
    private func addBlurEffect(bottomCoverImageView: UIImageView) {
        let blur = UIBlurEffect(style: .Light);
        let blurEffectView = UIVisualEffectView.init(effect: blur)
        blurEffectView.frame = self.view.bounds;
        bottomCoverImageView.addSubview(blurEffectView)
    }
    
    private func checkApiVersion() {
        loginViewModel.getCurrentApiVersion()
            .producer
            .takeUntil(self.rac_willDeallocSignalProducer())
            .observeOn(UIScheduler())
            .startWithSignal { [weak self] signal, _ in
                signal.observeResult{ result in
                    guard let value = result.value else {
                        return;
                    }
                    switch value {
                    case .OLD_VERSION:
                        self?.showUpdateAlert();
                        break;
                    default:
                        break;
                    }
                }
        }
    }
}
