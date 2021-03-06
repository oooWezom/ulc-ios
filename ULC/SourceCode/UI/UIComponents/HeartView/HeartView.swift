//
//  HeartView.swift
//  FloatingHeart
//
//  Created by Said Marouf on 9/22/15.
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import UIKit
import Foundation

// MARK: Themes

struct HeartTheme {
    let fillColor: UIColor
    let strokeColor: UIColor
    //using white borders for this example. Set your colors.
    static let availableThemes = [
        (UIColor(hex: 0xe66f5e), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6a69a0), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x81cc88), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfd3870), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6ecff6), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xc0aaf7), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xf7603b), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x39d3d3), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfed301), UIColor(white: 1.0, alpha: 0.8))
    ]

    static func randomTheme() -> HeartTheme {
        let r = Int(randomNumber(availableThemes.count))
        let theme = availableThemes[r]
        return HeartTheme(fillColor: theme.0, strokeColor: theme.1)
    }
}

// MARK: HeartView

enum RotationDirection: CGFloat {
    case Left = -1
    case Right = 1
}

let PI = CGFloat(M_PI)

public class HeartView: UIView {

    private struct Durations {
        static let Full: NSTimeInterval = 4.0
        static let Bloom: NSTimeInterval = 0.5
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        layer.anchorPoint = CGPoint(x: 0.5, y: 1)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: Animations

    public func animateInView(view: UIView) {
        guard let rotationDirection = RotationDirection(rawValue: CGFloat(1 - Int(2 * randomNumber(2)))) else { return }
        prepareForAnimation()
        performBloomAnimation()
        performSlightRotationAnimation(rotationDirection)
        addPathAnimation(inView: view)
    }

    private func prepareForAnimation() {
        transform = CGAffineTransformMakeScale(0, 0)
        alpha = 0
    }

    private func performBloomAnimation() {
        spring(Durations.Bloom, delay: 0.0, damping: 0.6, velocity: 0.8) {
            self.transform = CGAffineTransformIdentity
            self.alpha = 0.9
        }
    }

    private func performSlightRotationAnimation(direction: RotationDirection) {
        let rotationFraction = randomNumber(10)
        animate(Durations.Full, delay: 0) {
            self.transform = CGAffineTransformMakeRotation(direction.rawValue * PI / (16 + rotationFraction * 0.2))
        }
    }

    private func travelPath(inView view: UIView) -> UIBezierPath? {
        guard let endPointDirection = RotationDirection(rawValue: CGFloat(1 - Int(2 * randomNumber(2)))) else { return nil }

        let heartCenterX = center.x
        let heartSize = bounds.width
        let viewHeight = view.bounds.height

        //random end point
        let endPointX = heartCenterX + (endPointDirection.rawValue * randomNumber(5 * heartSize))
        let endPointY = viewHeight / 4.0 + randomNumber(viewHeight / 2.0) + randomNumber(10);
        let endPoint = CGPoint(x: endPointX, y: endPointY)

        //random Control Points
        let travelDirection = CGFloat(1 - Int(2 * randomNumber(2)))
        let xDelta = (heartSize / 2.0 + randomNumber(2 * heartSize)) * travelDirection
        let yDelta = max(endPoint.y ,max(randomNumber(8 * heartSize), heartSize))
        let controlPoint1 = CGPoint(x: heartCenterX + xDelta, y: viewHeight - yDelta)
        let controlPoint2 = CGPoint(x: heartCenterX - 2 * xDelta, y: yDelta)

        let path = UIBezierPath()
        path.moveToPoint(center)
        path.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        return path
    }

    private func addPathAnimation(inView view: UIView) {
        guard let heartTravelPath = travelPath(inView: view) else { return }
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = heartTravelPath.CGPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        let durationAdjustment = 4 * NSTimeInterval(heartTravelPath.bounds.height / view.bounds.height)
        let duration = Durations.Full + durationAdjustment
        keyFrameAnimation.duration = duration
        layer.addAnimation(keyFrameAnimation, forKey: "positionOnPath")

        animateToFinalAlpha(withDuration: duration)
    }

    private func animateToFinalAlpha(withDuration duration: NSTimeInterval = Durations.Full) {
        animate(duration, delay: 0,
            animations: {
                self.alpha = 0.0
            },
            completion: {
                self.removeFromSuperview()
            }
        )
    }

    override public func drawRect(rect: CGRect) {

#if true

        let theme = HeartTheme.randomTheme()
        let imageBundle = NSBundle(forClass: HeartView.self)
        let heartImage = UIImage(named: "heart_likes_count", inBundle: imageBundle, compatibleWithTraitCollection: nil)
        let heartImageBorder = UIImage(named: "heartBorder", inBundle: imageBundle, compatibleWithTraitCollection: nil)
    
        //Draw background image (mimics border)
        theme.strokeColor.setFill()
        heartImageBorder?.drawInRect(rect, blendMode: .Normal, alpha: 1.0)

        //Draw foreground heart image
        theme.fillColor.setFill()
        heartImage?.drawInRect(rect, blendMode: .Normal, alpha: 1.0)
#else
        //Just for fun. Draw heart using Bezier path
        drawHeartInRect(rect)
#endif
    }
    
    private func drawHeartInRect(rect: CGRect) {
        
        let theme = HeartTheme.randomTheme()

        theme.strokeColor.setStroke()
        theme.fillColor.setFill()
        
        let drawingPadding: CGFloat = 4.0
        let curveRadius = floor((CGRectGetWidth(rect) - 2 * drawingPadding) / 4.0)
        
        //Creat path
        let heartPath = UIBezierPath()
        
        //Start at bottom heart tip
        let tipLocation = CGPoint(x: floor(CGRectGetWidth(rect) / 2.0), y: CGRectGetHeight(rect) - drawingPadding)
        heartPath.moveToPoint(tipLocation)
        
        //Move to top left start of curve
        let topLeftCurveStart = CGPoint(x: drawingPadding, y: floor(CGRectGetHeight(rect) / 2.4))
        heartPath.addQuadCurveToPoint(topLeftCurveStart, controlPoint: CGPoint(x: topLeftCurveStart.x, y: topLeftCurveStart.y + curveRadius))
        
        //Create top left curve
        heartPath.addArcWithCenter(CGPoint(x: topLeftCurveStart.x + curveRadius, y: topLeftCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        //Create top right curve
        let topRightCurveStart = CGPoint(x: topLeftCurveStart.x + 2*curveRadius, y: topLeftCurveStart.y)
        heartPath.addArcWithCenter(CGPoint(x: topRightCurveStart.x + curveRadius, y: topRightCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        //Final curve to bottom heart tip
        let topRightCurveEnd = CGPoint(x: topLeftCurveStart.x + 4*curveRadius, y: topRightCurveStart.y)
        heartPath.addQuadCurveToPoint(tipLocation, controlPoint: CGPoint(x: topRightCurveEnd.x, y: topRightCurveEnd.y + curveRadius))
        
        heartPath.fill()
        
        heartPath.lineWidth = 1
        heartPath.lineCapStyle = .Round
        heartPath.lineJoinStyle = .Round
        heartPath.stroke()
    }
}
