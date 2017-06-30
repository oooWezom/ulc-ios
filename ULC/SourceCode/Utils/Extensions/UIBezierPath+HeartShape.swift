//
//  UI+HeartShape.swift
//  ULC
//
//  Created by Cruel Ultron on 6/12/17.
//  Copyright © 2017 wezom.com.ua. All rights reserved.
//

import UIKit

public extension UIBezierPath  {
    
    func getHearts(originalRect: CGRect, scale: Double) -> UIBezierPath {
        //Scaling will take bounds from the originalRect passed
        let scaledWidth = (originalRect.size.width * CGFloat(scale))
        let scaledXValue = ((originalRect.size.width) - scaledWidth) / 2
        let scaledHeight = (originalRect.size.height * CGFloat(scale))
        let scaledYValue = ((originalRect.size.height) - scaledHeight) / 2
        
        let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
        self.moveToPoint(CGPointMake(originalRect.size.width/2, scaledRect.origin.y + scaledRect.size.height))
        
        self.addCurveToPoint(CGPointMake(scaledRect.origin.x, scaledRect.origin.y + (scaledRect.size.height/4)),
                             controlPoint1:CGPointMake(scaledRect.origin.x + (scaledRect.size.width/2), scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                             controlPoint2: CGPointMake(scaledRect.origin.x, scaledRect.origin.y + (scaledRect.size.height/2)) )
        
        self.addArcWithCenter(CGPointMake( scaledRect.origin.x + (scaledRect.size.width/4),scaledRect.origin.y + (scaledRect.size.height/4)),
                              radius: (scaledRect.size.width/4),
                              startAngle: CGFloat(M_PI),
                              endAngle: 0,
                              clockwise: true)
        
        self.addArcWithCenter(CGPointMake( scaledRect.origin.x + (scaledRect.size.width * 3/4),scaledRect.origin.y + (scaledRect.size.height/4)),
                              radius: (scaledRect.size.width/4),
                              startAngle: CGFloat(M_PI),
                              endAngle: 0,
                              clockwise: true)
        
        self.addCurveToPoint(CGPointMake(originalRect.size.width/2, scaledRect.origin.y + scaledRect.size.height),
                             controlPoint1: CGPointMake(scaledRect.origin.x + scaledRect.size.width, scaledRect.origin.y + (scaledRect.size.height/2)),
                             controlPoint2: CGPointMake(scaledRect.origin.x + (scaledRect.size.width/2), scaledRect.origin.y + (scaledRect.size.height*3/4)) )
        self.closePath()
        return self
    }
}

