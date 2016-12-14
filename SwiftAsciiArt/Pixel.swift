//
//  Pixel.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/25/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import Foundation

/** Represents the memory address of a pixel. */
typealias PixelPointer = UnsafePointer<UInt8>

/** A point in an image converted to an ASCII character. */
struct Pixel
{
    /** The number of bytes a pixel occupies. 1 byte per channel (RGBA). */
    static let bytesPerPixel = 4
    
    fileprivate let offset: Int
    fileprivate init(_ offset: Int) { self.offset = offset }
    
    static func createPixelMatrix(_ width: Int, _ height: Int) -> [[Pixel]]
    {
        return (0..<height).map { row in
            (0..<width).map { col in
                let offset = (width * row + col) * Pixel.bytesPerPixel
                return Pixel(offset)
            }
        }
    }
    
    func intensityFromPixelPointer(_ pointer: PixelPointer) -> Double
    {
        let
        red   = pointer[offset + 0],
        green = pointer[offset + 1],
        blue  = pointer[offset + 2]
        return Pixel.calculateIntensity(red, green, blue)
    }
    
    fileprivate static func calculateIntensity(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> Double
    {
        // Normalize the pixel's grayscale value to between 0 and 1.
        // Weights from http://en.wikipedia.org/wiki/Grayscale#Luma_coding_in_video_systems
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
