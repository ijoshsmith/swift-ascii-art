//
//  Pixel.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/25/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import Foundation
import UIKit

/** Represents the memory address of a pixel. */
typealias PixelPointer = UnsafePointer<UInt8>

/** A point in an image converted to an ASCII character. */
struct Pixel
{
    let row: Int, col: Int
    
    static func createPixelMatrix(width: Int, _ height: Int) -> [[Pixel]]
    {
        let
        rows = [Int](0..<height),
        cols = [Int](0..<width)
        return rows.map { row in
            cols.map { col in
                Pixel(row: row, col: col)
            }
        }
    }
    
    func intensityFromPixelPointer(pixelPointer: PixelPointer, pixelsPerRow: Int) -> Double
    {
        let
        stride = 4, // each pixel occupies 4 bytes (RGBA)
        offset = (pixelsPerRow * row + col) * stride,
        red    = pixelPointer[offset + 0],
        green  = pixelPointer[offset + 1],
        blue   = pixelPointer[offset + 2]
        return Pixel.calculateIntensity(red, green, blue)
    }
    
    private static func calculateIntensity(r: UInt8, _ g: UInt8, _ b: UInt8) -> Double
    {
        /* 
         * Convert the pixel color to grayscale then normalize
         * the color channels' sum to a value between 0 and 1.
         */
        
        // Refer to http://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
        let
        redWeight   = 0.229,
        greenWeight = 0.587,
        blueWeight  = 0.114
        
        let maximum =
            255.0 * redWeight   +
            255.0 * greenWeight +
            255.0 * blueWeight
        
        let sum =
            Double(r) * redWeight   +
            Double(g) * greenWeight +
            Double(b) * blueWeight
        
        return sum / maximum
    }
}
