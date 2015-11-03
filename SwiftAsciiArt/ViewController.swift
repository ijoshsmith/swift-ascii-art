//
//  ViewController.swift
//  SwiftAsciiArt
//
//  Created by Joshua Smith on 4/25/15.
//  Copyright (c) 2015 iJoshSmith. All rights reserved.
//

import UIKit

class ViewController:
    UIViewController,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, // required by image picker
    UIScrollViewDelegate
{
    private let labelFont = UIFont(name: "Menlo", size: 7)!
    private let maxImageSize = CGSizeMake(310, 310)
    private lazy var palette: AsciiPalette = AsciiPalette(font: self.labelFont)
    
    private var currentLabel: UILabel?
    @IBOutlet weak var busyView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Setup
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.configureZoomSupport()
    }
    
    // MARK: - Actions
    
    @IBAction func handleKermitTapped(sender: AnyObject)
    {
        displayImageNamed("kermit")
    }
    
    @IBAction func handleBatmanTapped(sender: AnyObject)
    {
        displayImageNamed("batman")
    }
    
    @IBAction func handleMonkeyTapped(sender: AnyObject)
    {
        displayImageNamed("monkey")
    }
    
    @IBAction func handlePickImageTapped(sender: AnyObject)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.showViewController(imagePicker, sender: self)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            displayImage(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Rendering
    
    private func displayImageNamed(imageName: String)
    {
        displayImage(UIImage(named: imageName)!)
    }
    
    private func displayImage(image: UIImage)
    {
        self.busyView.hidden = false
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            
            let // Rotate first because the orientation is lost when resizing.
            rotatedImage = image.imageRotatedToPortraitOrientation(),
            resizedImage = rotatedImage.imageConstrainedToMaxSize(self.maxImageSize),
            asciiArtist  = AsciiArtist(resizedImage, self.palette),
            asciiArt     = asciiArtist.createAsciiArt()
            
            dispatch_async(dispatch_get_main_queue()) {
                self.displayAsciiArt(asciiArt)
                self.busyView.hidden = true
            }
            
            print(asciiArt)
        }
    }
    
    private func displayAsciiArt(asciiArt: String)
    {
        let label = UILabel()
        label.font = self.labelFont
        label.lineBreakMode = NSLineBreakMode.ByClipping
        label.numberOfLines = 0
        label.text = asciiArt
        label.sizeToFit()
        
        currentLabel?.removeFromSuperview()
        currentLabel = label
        
        scrollView.addSubview(label)
        scrollView.contentSize = label.frame.size
        
        self.updateZoomSettings(animated: false)
        scrollView.contentOffset = CGPointZero
    }
    
    // MARK: - Zooming support
    
    private func configureZoomSupport()
    {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5
    }
    
    private func updateZoomSettings(animated animated: Bool)
    {
        let
        scrollSize  = scrollView.frame.size,
        contentSize = scrollView.contentSize,
        scaleWidth  = scrollSize.width / contentSize.width,
        scaleHeight = scrollSize.height / contentSize.height,
        scale       = max(scaleWidth, scaleHeight)
        scrollView.minimumZoomScale = scale
        scrollView.setZoomScale(scale, animated: animated)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView?
    {
        return currentLabel
    }
}
