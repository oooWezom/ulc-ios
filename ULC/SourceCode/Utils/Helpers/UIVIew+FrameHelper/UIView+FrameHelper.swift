//
//  UIView+FrameHelper.swift
//  WayFarer
//
//  Created by Alex on 9/28/15.
//  Copyright © 2015 New Line Studio. All rights reserved.
//

import UIKit
import CoreGraphics

extension UIView {

    var x: CGFloat {
        get {
            return CGRectGetMinX(self.frame)
        }
        set {
            self.setPostion(newValue, yPosition: self.y)
        }
    }
    var y: CGFloat {
        get {
            return CGRectGetMinY(self.frame)
        }
        set {
            self.setPostion(self.x, yPosition: newValue)
        }
    }
    var width: CGFloat {
        get {
            return CGRectGetWidth(self.frame)
        }
        set {
            self.setSize(newValue, heightSize: self.height)
        }
    }
    var height: CGFloat {
        get {
            return CGRectGetHeight(self.frame)
        }
        set {
            self.setSize(self.width, heightSize: newValue)
        }
    }
    var xCenter: CGFloat {
        get {
            return CGRectGetMidX(self.frame)
        }
        set {
            var newPoint: CGPoint = self.center
            newPoint.x = newValue
            self.center = newPoint
        }
    }
    var yCenter: CGFloat {
        get {
            return CGRectGetMidY(self.frame)
        }
        set {
            var newPoint: CGPoint = self.center
            newPoint.y = newValue
            self.center = newPoint
        }
    }
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            self.setPostion(newValue.x, yPosition: newValue.y)
        }
    }
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            self.setSize(newValue.width, heightSize: newValue.height)
        }
    }
    var maxX: CGFloat {
        get {
            return CGRectGetMaxX(self.frame)
        }
    }
    var maxY: CGFloat {
        get {
            return CGRectGetMaxY(self.frame)
        }
    }
    var aspectRatio: CGFloat {
        get {
            return self.width / self.height
        }
    }
}

extension UIView {
    public func setPositionFromPoint(point: CGPoint) {
        self.setPostion(point.x, yPosition: point.y)
    }
    public func setSizeFromSize(newSize: CGSize) {
        self.setSize(newSize.width, heightSize: newSize.height)
    }
    public func adjustX(dx: CGFloat) {
        self.setAdjustPostion(dx, yAdjust: 0)
    }
    public func adjustY(dy: CGFloat) {
        self.setAdjustPostion(0, yAdjust: dy)
    }
    public func setAdjustPostion(xAdjust: CGFloat, yAdjust: CGFloat) {
        self.setPostion(self.x + xAdjust, yPosition: self.y + yAdjust)
    }
    public func adjustWidth(adjWidth: CGFloat) {
        self.setAdjustPostion(adjWidth, yAdjust: 0)
    }
    public func adjustHeight(adjHeight: CGFloat) {
        self.setAdjustPostion(0, yAdjust: adjHeight)
    }
    public func adjustSize(adjWidth: CGFloat, adjHeight: CGFloat) {
        self.setSize(self.width + adjWidth, heightSize: self.height + adjHeight)
    }
    public func scaleProportionalByPercent(factor: CGFloat) {
        self.setSize(self.width * factor, heightSize: self.height * factor)
    }
    public func scaleProportionallyToWidth(width: CGFloat) {
        let newHeight: CGFloat = (width / self.width) * self.height
        self.setSize(width, heightSize: newHeight)
    }
    public func scaleProportionallyToHeight(height: CGFloat) {
        let newWidth: CGFloat = (height / self.height) * self.width
        self.setSize(newWidth, heightSize: height)
    }
    public func centerXWith(view: UIView) {
        var point: CGPoint = self.superview!.convertPoint(view.center, fromView: view.superview)
        point.y = self.center.y
        self.center = point
    }
    public func centerYWith(view: UIView) {
        var point: CGPoint = self.superview!.convertPoint(view.center, fromView: view.superview)
        point.x = self.center.x
        self.center = point
    }
    public func centerWith(view: UIView) {
        let point: CGPoint = self.superview!.convertPoint(view.center, fromView: view.superview)
        self.center = point
    }
    //Center with rect
    public func centerInRect(rect: CGRect) {
        let centerX: CGFloat = rect.midX - rect.origin.x
        let centerY: CGFloat = rect.midY - rect.origin.y
        self.center = CGPointMake(centerX, centerY)
    }
    public func centerXInRect(rect: CGRect) {
        let centerX: CGFloat = rect.midX
        var frame: CGRect = self.frame
        frame.origin.x = (centerX - (frame.size.width / 2)) - rect.origin.x
        self.frame = frame
    }
    public func centerYInRect(rect: CGRect) {
        let centerY: CGFloat = rect.midY
        var frame: CGRect = self.frame
        frame.origin.y = (centerY - (frame.size.height / 2)) - rect.origin.y
        self.frame = frame
    }
    //Space from superView
    public func insideTopBy(spacing: CGFloat) {
        self.insideTopEdgeOfView(self.superview!, with: spacing)
    }
    public func insideRightEdgeBy(spacing: CGFloat) {
        self.insideRightEdgeOf(self.superview!, with: spacing)
    }
    public func insideBottomEdgeBy(spacing: CGFloat) {
        self.insideBottomEdgeOf(self.superview!, with: spacing)
    }
    public func insideLeftEdgeBy(spacing: CGFloat) {
        self.insideLeftEdgeOf(self.superview!, with: spacing)
    }
    //Space from view
    public func insideTopEdgeOfView(view: UIView, with spacing: CGFloat) {
        let inTargetSpace: CGPoint = CGPointMake(0, spacing)
        let point: CGPoint = self.superview!.convertPoint(inTargetSpace, fromView: view)
        self.y = point.y
    }
    public func insideRightEdgeOf(view: UIView, with spacing: CGFloat) {
        let pointSpace: CGPoint = CGPointMake(view.width - spacing - self.height, 0)
        let point: CGPoint = self.superview!.convertPoint(pointSpace, fromView: view)
        self.x = point.x
    }
    public func insideBottomEdgeOf(view: UIView, with spacing: CGFloat) {
        let pointSpace: CGPoint = CGPointMake(0, view.height - spacing - self.height)
        let point: CGPoint = self.superview!.convertPoint(pointSpace, fromView: view)
        self.y = point.y
    }
    public func insideLeftEdgeOf(view: UIView, with spacing: CGFloat) {
        let pointSpace: CGPoint = CGPointMake(spacing, 0)
        let point: CGPoint = self.superview!.convertPoint(pointSpace, fromView: view)
        self.x = point.x
    }
    //
    public func outsideTopEdgeOf(view: UIView, spacing: CGFloat) {
        let targetPoint: CGPoint = CGPointMake(0, -(spacing + self.height))
        let newPoint: CGPoint = self.superview!.convertPoint(targetPoint, fromView: view)
        self.y = newPoint.y
    }
    public func outsideRightEdgeOf(view: UIView, spacing: CGFloat) {
        let targetPoint: CGPoint = CGPointMake(spacing + view.width, 0)
        let newPoint: CGPoint = self.superview!.convertPoint(targetPoint, fromView: view)
        self.x = newPoint.x
    }
    public func outsideBottomEdgeOf(view: UIView, spacing: CGFloat) {
        let targetPoint: CGPoint = CGPointMake(0, -(spacing + view.height))
        let newPoint: CGPoint = self.superview!.convertPoint(targetPoint, fromView: view)
        self.y = newPoint.y
    }
    public func outsideLeftEdgeOf(view: UIView, spacing: CGFloat) {
        let targetPoint: CGPoint = CGPointMake(-(spacing + self.width), 0)
        let newPoint: CGPoint = self.superview!.convertPoint(targetPoint, fromView: view)
        self.x = newPoint.x
    }
    //
    public func outsideTopEdgeBy(spacing: CGFloat) {
        self.outsideTopEdgeOf(self.superview!, spacing: spacing)
    }
    public func outsideRightEdgeBy(spacing: CGFloat) {
        self.outsideRightEdgeOf(self.superview!, spacing: spacing)
    }
    public func outsideBottomEdgeBy(spacing: CGFloat) {
        self.outsideBottomEdgeOf(self.superview!, spacing: spacing)
    }
    public func outsideLeftEdgeBy(spacing: CGFloat) {
        self.outsideLeftEdgeOf(self.superview!, spacing: spacing)
    }

}

extension UIView {

    private func setPostion(xPostion: CGFloat, yPosition: CGFloat) {
        var newFrame: CGRect = self.frame
        newFrame.origin.x = xPostion
        newFrame.origin.y = yPosition
        self.frame = newFrame
    }

    private func setSize(widthSize: CGFloat, heightSize: CGFloat) {
        var newFrame: CGRect = self.frame
        newFrame.size.width = widthSize
        newFrame.size.height = heightSize
        self.frame = newFrame
    }
}
