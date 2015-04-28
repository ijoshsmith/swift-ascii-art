//
//  AsciiArtist.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/25/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import Foundation
import UIKit

/** Transforms an image to ASCII art. */
class AsciiArtist
{
    private let
    image:   UIImage,
    palette: AsciiPalette
    
    init(_ image: UIImage, _ palette: AsciiPalette)
    {
        self.image   = image
        self.palette = palette
    }
    
    func createAsciiArt() -> String
    {
        let
        dataProvider = CGImageGetDataProvider(image.CGImage),
        pixelData    = CGDataProviderCopyData(dataProvider),
        pixelPointer = CFDataGetBytePtr(pixelData),
        intensities  = intensityMatrixFromPixelPointer(pixelPointer),
        symbolMatrix = symbolMatrixFromIntensityMatrix(intensities)
        return join("\n", symbolMatrix)
    }
    
    private func intensityMatrixFromPixelPointer(pointer: PixelPointer) -> [[Double]]
    {
        let
        width  = Int(image.size.width),
        height = Int(image.size.height),
        matrix = Pixel.createPixelMatrix(width, height)
        return matrix.map { pixelRow in
            pixelRow.map { pixel in
                pixel.intensityFromPixelPointer(pointer)
            }
        }
    }
    
    private func symbolMatrixFromIntensityMatrix(matrix: [[Double]]) -> [String]
    {
        return matrix.map { intensityRow in
            intensityRow.reduce("") {
                $0 + self.symbolFromIntensity($1)
            }
        }
    }
    
    private func symbolFromIntensity(intensity: Double) -> String
    {
        assert(0.0 <= intensity && intensity <= 1.0)
        
        let
        factor = palette.symbols.count - 1,
        value  = round(intensity * Double(factor)),
        index  = Int(value)
        return palette.symbols[index]
    }
}
