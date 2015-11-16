//
//  UIImage+Util.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/26/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

extension UIImage
{
    class func imageOfSymbol(symbol: String, _ font: UIFont) -> UIImage
    {
        let
        length = font.pointSize * 2,
        size   = CGSizeMake(length, length),
        rect   = CGRect(origin: CGPointZero, size: size)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()

        // Fill the background with white.
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, rect)
        
        // Draw the character with black.
        let nsString = NSString(string: symbol)
        nsString.drawAtPoint(rect.origin, withAttributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.blackColor()
            ])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageConstrainedToMaxSize(maxSize: CGSize) -> UIImage
    {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig
        {
            let
            maxRect       = CGRect(origin: CGPointZero, size: maxSize),
            scaledRect    = AVMakeRectWithAspectRatioInsideRect(self.size, maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPointZero, size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.CGImage,
            bitsPerComp   = CGImageGetBitsPerComponent(cgImage),
            compsPerPixel = 4, // RGBA
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = CGImageGetColorSpace(cgImage),
            bitmapInfo    = CGImageGetBitmapInfo(cgImage),
            context       = CGBitmapContextCreate(
                nil,
                width,
                height,
                bitsPerComp,
                bytesPerRow,
                colorSpace,
                bitmapInfo.rawValue)
        
            if context != nil
            {
                CGContextSetInterpolationQuality(context, CGInterpolationQuality.Low)
                CGContextDrawImage(context, targetRect, CGImage)
                if let scaledCGImage = CGBitmapContextCreateImage(context)
                {
                    return UIImage(CGImage: scaledCGImage)
                }
            }
        }
        return self
    }
    
    func imageRotatedToPortraitOrientation() -> UIImage
    {
        let mustRotate = self.imageOrientation != .Up
        if mustRotate
        {
            let rotatedSize = CGSizeMake(size.height, size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext()
            {
                // Perform the rotation and scale transforms around the image's center.
                CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2)
                
                // Rotate the image upright.
                let
                degrees = self.degreesToRotate(),
                radians = degrees * M_PI / 180.0
                CGContextRotateCTM(context, CGFloat(radians))
                
                // Flip the image on the Y axis.
                CGContextScaleCTM(context, 1.0, -1.0)
                
                let
                targetOrigin = CGPointMake(-size.width/2, -size.height/2),
                targetRect   = CGRect(origin: targetOrigin, size: self.size)
                
                CGContextDrawImage(context, targetRect, self.CGImage)
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                return rotatedImage
            }
        }
        return self
    }
    
    private func degreesToRotate() -> Double
    {
        switch self.imageOrientation
        {
        case .Right: return  90
        case .Down:  return 180
        case .Left:  return -90
        default:     return   0
        }
    }
}
