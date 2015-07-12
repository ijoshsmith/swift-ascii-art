//
//  AsciiPalette.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/26/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import Foundation
import UIKit

/** Provides a list of ASCII symbols sorted from darkest to brightest. */
public class AsciiPalette
{
    private let font: UIFont
    
    public init(font: UIFont) { self.font = font }
    
    public lazy var symbols: [String] = self.loadSymbols()
    
    private func loadSymbols() -> [String]
    {
        return symbolsSortedByIntensityForAsciiCodes(32...126) // from ' ' to '~'
    }
    
    private func symbolsSortedByIntensityForAsciiCodes(codes: Range<Int>) -> [String]
    {
        let
        symbols          = codes.map { self.symbolFromAsciiCode($0) },
        symbolImages     = symbols.map { UIImage.imageOfSymbol($0, self.font) },
        whitePixelCounts = symbolImages.map { self.countWhitePixelsInImage($0) },
        sortedSymbols    = sortByIntensity(symbols, whitePixelCounts)
        return sortedSymbols
    }
    
    private func symbolFromAsciiCode(code: Int) -> String
    {
        return String(Character(UnicodeScalar(code)))
    }
    
    private func countWhitePixelsInImage(image: UIImage) -> Int
    {
        let
        dataProvider = CGImageGetDataProvider(image.CGImage),
        pixelData    = CGDataProviderCopyData(dataProvider),
        pixelPointer = CFDataGetBytePtr(pixelData),
        byteCount    = CFDataGetLength(pixelData),
        pixelOffsets = stride(from: 0, to: byteCount, by: Pixel.bytesPerPixel)
        return reduce(pixelOffsets, 0) { (count, offset) -> Int in
            let
            r = pixelPointer[offset + 0],
            g = pixelPointer[offset + 1],
            b = pixelPointer[offset + 2],
            isWhite = (r == 255) && (g == 255) && (b == 255)
            return isWhite ? count + 1 : count
        }
    }
    
    private func sortByIntensity(symbols: [String], _ whitePixelCounts: [Int]) -> [String]
    {
        let
        mappings      = NSDictionary(objects: symbols, forKeys: whitePixelCounts),
        uniqueCounts  = Set(whitePixelCounts),
        sortedCounts  = sorted(uniqueCounts),
        sortedSymbols = sortedCounts.map { mappings[$0] as! String }
        return sortedSymbols
    }
}
