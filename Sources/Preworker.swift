//
//  Preworker.swift
//  Preworker
//
//  Created by James Richard on 7/13/14.
//  Copyright (c) 2014 James Richard. All rights reserved.
//

import Foundation

public class Preworker<T> {
    public typealias WorkHandler = (context: PreworkerContext<T>) -> (result: T?, error: NSError?)
    public typealias ProgressHandler = (progress: Float) -> ()
    
    public var isStarted: Bool {
    return started
    }
    
    public var isFinished: Bool {
    return finished
    }
    
    public var progressHandler: ProgressHandler?
    public var progress: Float {
        return context.progress
    }
    
    private var workResult: T?
    private var workError: NSError?
    private var started = false
    private var finished = false
    private let work: WorkHandler
    private let workLock = NSLock()
    private let dispatchGroup = dispatch_group_create()
    private let dispatchQueue: dispatch_queue_t
    lazy private var context: PreworkerContext<T> = PreworkerContext<T>(preworker: self)
    
    
    public init(queue: dispatch_queue_t, work: WorkHandler) {
        dispatchQueue = queue
        self.work = work
    }
    
    public convenience init(work: WorkHandler) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        self.init(queue: queue, work: work)
    }
    
    public func start() -> Self {
        workLock.lock()
        
        if started {
            workLock.unlock()
            debugPrintln("WARNING: Attempted to start a Preworker that has already been started")
            return self
        }
        
        dispatch_group_async(dispatchGroup, dispatchQueue) {
            let result = self.work(context: self.context)
            self.workResult = result.result
            self.workError = result.error
            self.finished = true
        }
        
        started = true
        workLock.unlock()
        
        return self
    }
    
    public func result() -> (result: T?, error: NSError?) {
        dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
        
        return (result: workResult, error: workError)
    }
    
    public func result(queue: dispatch_queue_t! = dispatch_get_main_queue(), handler: (result: T?, error: NSError?) -> ()) {
        assert(queue, "You must pass in a valid dispatch queue")

        dispatch_group_notify(dispatchGroup, queue) {
            handler(result: self.workResult, error: self.workError)
        }
    }
    
    public func retry() {
        if !finished {
            debugPrintln("WARNING: Will not retry Preworker because it is not yet finished")
            return
        }
        
        finished = false
        started = false
        start()
    }
}
