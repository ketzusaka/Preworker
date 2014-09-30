//
//  TimeoutsViewController.swift
//  Preworker
//
//  Created by James Richard on 9/17/14.
//  Copyright (c) 2014 LucidCoding. All rights reserved.
//

import UIKit

class TimeoutsViewController: UIViewController {
    var worker: Preworker<String>!
    @IBOutlet var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        worker = Preworker<String> { _ in
            sleep(10)
            return ("The slowly created string", nil)
        }.start()
        
        worker.result { [unowned self] result, error in
            if let result = result {
                self.resultLabel.text = result
            }
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // This result will timeout after two seconds
            let result = self.worker.result(timeoutWithDelay: 2.0)
            println("Error for 2 second wait result: \(result.error)")
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // This result will timeout after four seconds
            let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 4))
            let result = self.worker.result(timeout: timeout)
            println("Error for 4 second wait result: \(result.error)")
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            // This result waits forever
            let result = self.worker.result()
            println("Resulting string on forever timeout: \(result.result!)")
        }
    }
}
