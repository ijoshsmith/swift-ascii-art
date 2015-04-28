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
    let
    row: Int,
    col: Int
    
    private init(_ row: Int, _ col: Int)
    {
        self.row = row
        self.col = col
    }
    
    static func createPixelMatrix(width: Int, _ height: Int) -> [[Pixel]]
    {
        return map(0..<height) { row in
            map(0..<width) { col in
                Pixel(row, col)
            }
        }
    }
    
    func intensityFromPixelPointer(pointer: PixelPointer, pixelsPerRow: Int) -> Double
    {
        let
        stride = 4, // each pixel occupies 4 bytes (RGBA)
        offset = (pixelsPerRow * row + col) * stride,
        red    = pointer[offset + 0],
        green  = pointer[offset + 1],
        blue   = pointer[offset + 2]
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
        blueWeight  = 0.114,
        weightedMax = 255.0 * redWeight   +
                      255.0 * greenWeight +
                      255.0 * blueWeight,
        weightedSum = Double(r) * redWeight   +
                      Double(g) * greenWeight +
                      Double(b) * blueWeight
        return weightedSum / weightedMax
    }
}
