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
    width:   Int,
    height:  Int,
    palette: AsciiPalette
    
    init(_ image: UIImage, _ palette: AsciiPalette)
    {
        self.image   = image
        self.width   = Int(image.size.width)
        self.height  = Int(image.size.height)
        self.palette = palette
    }
    
    func createAsciiArt() -> String
    {
        let
        dataProvider = CGImageGetDataProvider(image.CGImage),
        pixelData    = CGDataProviderCopyData(dataProvider),
        pixelPointer = CFDataGetBytePtr(pixelData),
        intensities  = intensityMatrixFromPixelPointer(pixelPointer),
        symbolLines  = symbolLinesFromIntensityMatrix(intensities),
        joinedLines  = join("\n", symbolLines)
        return joinedLines
    }
    
    private func intensityMatrixFromPixelPointer(pointer: PixelPointer) -> [[Double]]
    {
        let matrix = Pixel.createPixelMatrix(width, height)
        return matrix.map { pixelRow in
            pixelRow.map {
                $0.intensityFromPixelPointer(pointer, self.width)
            }
        }
    }
    
    private func symbolLinesFromIntensityMatrix(matrix: [[Double]]) -> [String]
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
        index  = Int(value),
        symbol = palette.symbols[index]
        return symbol
    }
}
