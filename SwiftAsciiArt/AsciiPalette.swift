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
class AsciiPalette
{
    fileprivate let font: UIFont
    
    init(font: UIFont) { self.font = font }
    
    lazy var symbols: [String] = self.loadSymbols()
    
    fileprivate func loadSymbols() -> [String]
    {
        return symbolsSortedByIntensityForAsciiCodes(32...126) // from ' ' to '~'
    }
    
    fileprivate func symbolsSortedByIntensityForAsciiCodes(_ codes: CountableClosedRange<Int>) -> [String]
    {
        let
        symbols          = codes.map { self.symbolFromAsciiCode($0) },
        symbolImages     = symbols.map { UIImage.imageOfSymbol($0, self.font) },
        whitePixelCounts = symbolImages.map { self.countWhitePixelsInImage($0) },
        sortedSymbols    = sortByIntensity(symbols, whitePixelCounts)
        return sortedSymbols
    }
    
    fileprivate func symbolFromAsciiCode(_ code: Int) -> String
    {
        return String(Character(UnicodeScalar(code)!))
    }
    
    fileprivate func countWhitePixelsInImage(_ image: UIImage) -> Int
    {
        let
        dataProvider = image.cgImage?.dataProvider,
        pixelData    = dataProvider?.data,
        pixelPointer = CFDataGetBytePtr(pixelData),
        byteCount    = CFDataGetLength(pixelData),
        pixelOffsets = stride(from: 0, to: byteCount, by: Pixel.bytesPerPixel)
        return pixelOffsets.reduce(0) { (count, offset) -> Int in
            let
            r = pixelPointer?[offset + 0],
            g = pixelPointer?[offset + 1],
            b = pixelPointer?[offset + 2],
            isWhite = (r == 255) && (g == 255) && (b == 255)
            return isWhite ? count + 1 : count
        }
    }
    
    fileprivate func sortByIntensity(_ symbols: [String], _ whitePixelCounts: [Int]) -> [String]
    {
        let
        mappings      = NSDictionary(objects: symbols, forKeys: whitePixelCounts as [NSCopying]),
        uniqueCounts  = Set(whitePixelCounts),
        sortedCounts  = uniqueCounts.sorted(),
        sortedSymbols = sortedCounts.map { mappings[$0] as! String }
        return sortedSymbols
    }
}
