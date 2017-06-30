//
//  CurrentUserProfileViewController+Delegates.swift
//  ULC
//
//  Created by Alex on 2/24/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit
import MBProgressHUD
import REFrostedViewController
import RSKImageCropper
import ReactiveCocoa

extension CurrentUserProfileViewController: RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        dismissViewControllerAnimated(true) { [unowned self] in
            
            let cropVC = RSKImageCropViewController(image: pickedImage, cropMode: .Custom)
            
            cropVC.delegate = self;
            cropVC.dataSource = self;
            
            guard   let containerVC = UIApplication.topViewController() as? ContainerViewController,
                let contentVC = containerVC.contentViewController as? UINavigationController else {
                    return;
            }
            self.closeMenu();
            contentVC.pushViewController(cropVC, animated: true);
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - RSKImageCropViewControllerDataSource
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
    }
    
    func imageCropViewControllerCustomMaskRect(controller: RSKImageCropViewController) -> CGRect {
        
        var maskSize = CGSizeMake(0, 0);
        let viewWidth = CGRectGetWidth(self.view.bounds);
        let viewHeight = CGRectGetHeight(self.view.bounds);
        
        switch avatarType {
        case .Circle:
            maskSize = CGSizeMake(circleAvatarView.width * 2, circleAvatarView.width * 2)
            break;
            
        default:
            maskSize = userHeaderView.bounds.size;
            break;
        }
        
        maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5, (viewHeight - maskSize.height) * 0.5, maskSize.width, maskSize.height);
        return maskRect;
    }
    
    func imageCropViewControllerCustomMaskPath(controller: RSKImageCropViewController) -> UIBezierPath {
        
        switch avatarType {
        case .Circle:
            return UIBezierPath(ovalInRect: maskRect);
        default:
            return UIBezierPath(rect: maskRect);
        }
    }
    
    // MARK: - RSKImageCropViewControllerDelegate
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        if let navigationController = self.navigationController {
            navigationController.popViewControllerAnimated(true)
        }
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, willCropImage originalImage: UIImage) {
        MBProgressHUD.showHUDAddedTo(controller.view, animated: true)
    }
    
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        
        guard let resultData = UIImagePNGRepresentation(croppedImage) else {
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            return
        }
        
        let base64ImageData = resultData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.init(rawValue: 0));
        
        userProfileViewModel.updateAvatarOrBackground(avatarType == .Circle ? base64ImageData : "", backgorunUrlData: avatarType == .Background ? base64ImageData : "")
            .takeUntil(self.rac_willDeallocSignalProducer())
            .producer
            .observeOn(UIScheduler())
            .startWithSignal { [weak self](observer, disposable) -> () in
                
                observer.observeResult({ observer in
                    guard let url = observer.value where !url.isEmpty else {
                        return;
                    }
                    
                    if self?.avatarType == .Circle {
                        self?.circleAvatarView.updateCircleAvatar(url);
                    } else {
                        self?.updateBackgroundImage(url);
                    }
                })
                
                observer.observeCompleted({
                    if let navigationController = self?.navigationController {
                        self?.tableView.reloadData();
                        navigationController.popViewControllerAnimated(true)
                    }
                })
                observer.observeFailed({ (let error) in
                    MBProgressHUD.hideAllHUDsForView(self?.view, animated: true)
                })
        }
    }
}
