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
    private let font: UIFont
    
    init(font: UIFont)
    {
        self.font = font
    }
    
    lazy var symbols: [String] = self.loadSymbols()
    
    private func loadSymbols() -> [String]
    {
        // Start with ' ' and end at '~'
        let asciiCodes = [Int](32...126)
        return symbolsSortedByIntensityForAsciiCodes(asciiCodes)
    }
    
    private func symbolsSortedByIntensityForAsciiCodes(codes: [Int]) -> [String]
    {
        let
        unsortedSymbols  = codes.map { self.symbolFromAsciiCode($0) },
        symbolRenderings = unsortedSymbols.map { UIImage.imageOfSymbol($0, font: self.font) },
        whitePixelCounts = symbolRenderings.map { self.whitePixelsInRendering($0) },
        sortedSymbols    = sortSymbolsByColorIntensity(unsortedSymbols, whitePixelCounts)
        return sortedSymbols
    }
    
    private func symbolFromAsciiCode(code: Int) -> String
    {
        return String(Character(UnicodeScalar(code)))
    }
    
    private func whitePixelsInRendering(rendering: UIImage) -> Int
    {
        let
        dataProvider = CGImageGetDataProvider(rendering.CGImage),
        pixelData    = CGDataProviderCopyData(dataProvider),
        byteCount    = CFDataGetLength(pixelData),
        pixelPointer = CFDataGetBytePtr(pixelData),
        pixelIndexes = stride(from: 0, to: byteCount, by: 4)
        
        return Array(pixelIndexes).reduce(0) { (sum, index) -> Int in
            let
            r = pixelPointer[index + 0],
            g = pixelPointer[index + 1],
            b = pixelPointer[index + 2],
            isWhite = (r == 255) && (g == 255) && (b == 255)
            return isWhite ? sum + 1 : sum
        }
    }
    
    private func sortSymbolsByColorIntensity(symbols: [String], _ whitePixelCounts: [Int]) -> [String]
    {
        let
        codeMappings  = NSDictionary(objects: symbols, forKeys: whitePixelCounts),
        uniqueCounts  = Set(whitePixelCounts),
        sortedCounts  = sorted(uniqueCounts),
        sortedSymbols   = sortedCounts.map { codeMappings[$0] as! String }
        return sortedSymbols
    }
}
