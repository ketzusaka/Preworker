//
//  ImageProcessingViewController.swift
//  Preworker
//
//  Created by James Richard on 7/16/14.
//  Copyright (c) 2014 LucidCoding. All rights reserved.
//

import UIKit
import CoreImage

class ImageProcessingViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var processBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    public var imageWorker: Preworker<UIImage>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        imageWorker = Preworker<UIImage>() { (context) in
//            let originalImage = UIImage(named: "Space")
//            context.progress = 0.1
//            // Setup a couple image filters so this takes a while
//            let coreImage = CIImage(CGImage: originalImage.CGImage)
//            context.progress = 0.15
//            let blurFilter = CIFilter(name: "CIGaussianBlur")
//            context.progress = 0.2
//            blurFilter.setValue(coreImage, forKey: kCIInputImageKey)
//            context.progress = 0.3
//            let blurResult = blurFilter.valueForKey(kCIOutputImageKey) as CIImage
//            context.progress = 0.4
//            let bumpFilter = CIFilter(name: "CIBumpDistortion")
//            context.progress = 0.5
//            bumpFilter.setValue(blurResult, forKey: kCIInputImageKey)
//            bumpFilter.setValue(CIVector(x: originalImage.size.width / 2, y: originalImage.size.height / 2), forKey: kCIInputCenterKey)
//            bumpFilter.setValue(500.0, forKey: kCIInputRadiusKey)
//            bumpFilter.setValue(5.0, forKey: kCIInputScaleKey)
//            context.progress = 0.6
//            let result = bumpFilter.valueForKey(kCIOutputImageKey) as CIImage
//            let cicontext = CIContext(options: nil)
//            let resultingCGImage = cicontext.createCGImage(result, fromRect: result.extent())
//            context.progress = 0.7
//            
//            // Have to hop through some hoops to get the image to render on the background thread and not the main thread
//            // when setting the image on the image view
//            let colorSpace = CGColorSpaceCreateDeviceRGB()
//            let bitmapInfo = CGBitmapInfo.fromRaw(CGImageAlphaInfo.PremultipliedLast.toRaw())!
//            let cgcontext = CGBitmapContextCreate(nil, UInt(result.extent().size.width), UInt(result.extent().size.height), 8, 0, colorSpace, bitmapInfo)
//            CGContextDrawImage(cgcontext, result.extent(), resultingCGImage)
//            context.progress = 0.8
//            let contextCGImage = CGBitmapContextCreateImage(cgcontext)
//            context.progress = 0.9
//            
//            let resultingImage = UIImage(CGImage: contextCGImage, scale: UIScreen.mainScreen().scale, orientation: .Up)
//            context.progress = 1.0
//            
//            return (result: resultingImage, error: nil)
//        }.start()
    }
    
    @IBAction func processPressed(sender: UIButton) {
//        sender.enabled = false
//        progressView.progress = imageWorker.progress
//        progressView.hidden = false
//        
//        imageWorker.progressHandler = { self.progressView.progress = $0 }
//        
//        imageWorker.result { (result, error) in
//            sender.enabled = true
//            self.imageView.image = result
//            self.progressView.hidden = true
//        }
    }
}
