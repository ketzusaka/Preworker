//
//  Preworker.swift
//  Preworker
//
//  Created by James Richard on 7/13/14.
//  Copyright (c) 2014 James Richard. All rights reserved.
//

import Foundation

/**
    An instance of a Preworker defines a unit of work that is to be done
    asynchronously. It takes a generic type which will be the result of
    the work done.

    Preworkers are thread-safe, and the work is executed on a background thread
    unless you specificly define the queue as the main thread.
*/
public class Preworker<T> {
    /// The closure used to define the unit of work to be done. See the PreworkerContext class for information about the context.
    public typealias WorkHandler = (context: PreworkerContext<T>) -> (result: T?, error: NSError?)
    
    /// The closure used to report progress on the work being done.
    public typealias ProgressHandler = (progress: Float) -> Void
    
    /// Whether or not the work has started. This value is reset to false if the work is retried.
    public private(set) var started = false
    
    /// Whether or not the work has finished. This value is reset to false if the work is retried.
    public private(set) var finished = false
    
    /// This closure is executed when the unit of work reports the progress has changed.
    public var progressHandler: ProgressHandler?
    
    /** 
        This is the current progress that the unit of work is reporting. Note that
        a unit of work can be completed while the progress is still zero since
        progress reporting is defined by the client.
    */
    public var progress: Float {
        return context.progress
    }
    
    /// The result of the unit of work.
    private var workResult: T?
    
    /// The error caused from the unit of work.
    private var workError: NSError?
    
    /// The work that will be done when started.
    private let work: WorkHandler
    
    /// This lock is used to prevent starting the work at the same from different threads.
    private let workLock = NSLock()
    
    /// The dispatch group used to place the work in.
    private let dispatchGroup = dispatch_group_create()
    
    /// The dispatch queue to run the work in.
    private let dispatchQueue: dispatch_queue_t
    
    /// The PreworkerContext that is used to help manage the work.
    lazy private var context: PreworkerContext<T> = PreworkerContext<T>(preworker: self)
    
    /**
        Initialize a Preworker. Remember that you must start a preworker before 
        it will begin its work.
    
        :param:     queue   The dispatch queue that the work should be done in.
        :param:     work    The unit of work that this worker executes.
    */
    public init(queue: dispatch_queue_t, work: WorkHandler) {
        dispatchQueue = queue
        self.work = work
    }
    
    /**
        Initialize a preworker using a background queue. Remember that you must start
        a preworker before it will begin its work.
        
        :param:     work    The unit of work that this worker executes.
    */
    public convenience init(work: WorkHandler) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        self.init(queue: queue, work: work)
    }
    
    /// Begin executing the unit of work.
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
    
    /**
        Synchronously wait for the result of the work. By default, this method will wait forever
        for the work to complete, you can pass in a dispatch time to specify when the wait should end.
    
        :param:     timeout     The timeout for waiting on the result of the work. By default, this is forever.
        :return:    A tuple with an optional result and optional error. Only one of the tuple parameters will have
                    a value. When the work was successful result will contain the result of the work. When
                    the work failed, or the timeout was reached, error will contain the error.
    */
    public func result(timeout: dispatch_time_t = DISPATCH_TIME_FOREVER) -> (result: T?, error: NSError?) {
        let waitResult = dispatch_group_wait(dispatchGroup, timeout)
        
        if waitResult != 0 {
            let userInfo = [NSLocalizedDescriptionKey: "The timeout for the work to finish was exceeded"]
            let error = NSError(domain: ErrorDomain, code: ErrorCodes.TimeoutExceeded, userInfo: userInfo)
            return (result: nil, error: error)
        }
        
        return (result: workResult, error: workError)
    }
    
    /**
        Synchronously wait for the result of the work. This is a convenience method for waiting
        a number of seconds before timing out.
        
        :param:     delay     The amount of time, in seconds, we will wait for the result of the work.
        :return:    A tuple with an optional result and optional error. Only one of the tuple parameters will have
        a value. When the work was successful result will contain the result of the work. When
        the work failed, or the timeout was reached, error will contain the error.
    */
    public func result(timeoutWithDelay delay: Double) -> (result: T?, error: NSError?) {
        let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        return result(timeout: timeout)
    }
    
    /**
        Asynchronously wait for the result of the work. By default, this method will execute the handling closure
        on the main queue, but you can specify which queue you would like to execute it on.
        
        :param:     queue       The queue to execute the handling closure on. This parameter defaults to the main queue.
        :param:     handler     A closure that is executed when the work is completed with an optional result and optional error.
                                Only one of the tuple parameters will have a value. When the work was successful result will 
                                contain the result of the work. When the work failed error will contain the error.
    */
    public func result(queue: dispatch_queue_t = dispatch_get_main_queue(), handler: (result: T?, error: NSError?) -> ()) {
        dispatch_group_notify(dispatchGroup, queue) {
            handler(result: self.workResult, error: self.workError)
        }
    }
    
    /// Retry the unit of work. This will only execute if the work was finished.
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
