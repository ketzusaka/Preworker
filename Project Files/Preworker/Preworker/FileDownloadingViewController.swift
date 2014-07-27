//
//  FileDownloadingViewController.swift
//  Preworker
//
//  Created by James Richard on 7/24/14.
//  Copyright (c) 2014 LucidCoding. All rights reserved.
//

import UIKit

class FileDownloadingViewController: UIViewController {
    var downloadWorker: Preworker<NSData>!
    
    @IBOutlet var downloadBtn: UIButton!
    @IBOutlet var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadWorker = Preworker<NSData> { context in
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            context++
            var downloadData: NSData?
            var downloadError: NSError?
            let task = session.dataTaskWithURL(NSURL(string: "http://ipv4.download.thinkbroadband.com/100MB.zip")) { data, response, error in
                downloadData = data
                downloadError = error
                context--
            }
            
            task.resume()
            
            context.waitForPendingOperations()
            
            return (downloadData, downloadError)
        }
    }
    
    @IBAction func downloadPressed(sender: UIButton) {
        sender.enabled = false
        statusLabel.hidden = false
        downloadWorker.result { result, error in
            if error {
                self.statusLabel.text = "Download failed :("
            } else {
                self.statusLabel.text = "Downloaded!"
            }
        }
    }
}
