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
    class func imageOfSymbol(_ symbol: String, _ font: UIFont) -> UIImage
    {
        let
        length = font.pointSize * 2,
        size   = CGSize(width: length, height: length),
        rect   = CGRect(origin: CGPoint.zero, size: size)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()

        // Fill the background with white.
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(rect)
        
        // Draw the character with black.
        let nsString = NSString(string: symbol)
        nsString.draw(at: rect.origin, withAttributes: [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.black
            ])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func imageConstrainedToMaxSize(_ maxSize: CGSize) -> UIImage
    {
        let isTooBig =
            size.width  > maxSize.width ||
            size.height > maxSize.height
        if isTooBig
        {
            let
            maxRect       = CGRect(origin: CGPoint.zero, size: maxSize),
            scaledRect    = AVMakeRect(aspectRatio: self.size, insideRect: maxRect),
            scaledSize    = scaledRect.size,
            targetRect    = CGRect(origin: CGPoint.zero, size: scaledSize),
            width         = Int(scaledSize.width),
            height        = Int(scaledSize.height),
            cgImage       = self.cgImage,
            bitsPerComp   = cgImage?.bitsPerComponent,
            compsPerPixel = 4, // RGBA
            bytesPerRow   = width * compsPerPixel,
            colorSpace    = cgImage?.colorSpace,
            bitmapInfo    = cgImage?.bitmapInfo,
            context       = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComp!,
                bytesPerRow: bytesPerRow,
                space: colorSpace!,
                bitmapInfo: (bitmapInfo?.rawValue)!)
        
            if context != nil
            {
                context!.interpolationQuality = CGInterpolationQuality.low
                context?.draw(cgImage!, in: targetRect)
                if let scaledCGImage = context?.makeImage()
                {
                    return UIImage(cgImage: scaledCGImage)
                }
            }
        }
        return self
    }
    
    func imageRotatedToPortraitOrientation() -> UIImage
    {
        let mustRotate = self.imageOrientation != .up
        if mustRotate
        {
            let rotatedSize = CGSize(width: size.height, height: size.width)
            UIGraphicsBeginImageContext(rotatedSize)
            if let context = UIGraphicsGetCurrentContext()
            {
                // Perform the rotation and scale transforms around the image's center.
                context.translateBy(x: rotatedSize.width/2, y: rotatedSize.height/2)
                
                // Rotate the image upright.
                let
                degrees = self.degreesToRotate(),
                radians = degrees * M_PI / 180.0
                context.rotate(by: CGFloat(radians))
                
                // Flip the image on the Y axis.
                context.scaleBy(x: 1.0, y: -1.0)
                
                let
                targetOrigin = CGPoint(x: -size.width/2, y: -size.height/2),
                targetRect   = CGRect(origin: targetOrigin, size: self.size)
                
                context.draw(self.cgImage!, in: targetRect)
                let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                
                return rotatedImage
            }
        }
        return self
    }
    
    fileprivate func degreesToRotate() -> Double
    {
        switch self.imageOrientation
        {
        case .right: return  90
        case .down:  return 180
        case .left:  return -90
        default:     return   0
        }
    }
}
