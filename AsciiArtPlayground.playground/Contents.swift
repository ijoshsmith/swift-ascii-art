
import UIKit
import SwiftAsciiArt_iOS
//: If there is an error with this import, select the SwiftAsciiArt_iOS scheme at the top left of the window and perform Command + B on the keyboard to build the framework.
import XCPlayground
//: The Palette analyzes a font to determine which characters are darker / lighter. That way the Artist can use that infomration to convert pixels into characters.
let font = UIFont(name: "Menlo", size: 7)!
let palette = AsciiPalette(font: font)
//: Here's the image we'll convert
let image = UIImage(named: "kermit.png")!
//: Creating the artist and instructing it to convert the image into a big long string
let artist = AsciiArtist(image: image, palette: palette)
let asciiArt = artist.createAsciiArt()
//: Creating a UILabel to show the string
let asciiLabel = UILabel()
asciiLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
asciiLabel.font = font
asciiLabel.lineBreakMode = NSLineBreakMode.ByClipping
asciiLabel.numberOfLines = 0
//: Adding the string into the text label and making it resize itself
asciiLabel.text = asciiArt
asciiLabel.sizeToFit()
//: **Show Assistant Editor –** View > Assistant Editor > Show
XCPShowView("asciiView", asciiLabel)
