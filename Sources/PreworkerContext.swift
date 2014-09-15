//
//  PreworkerContext.swift
//  Preworker
//
//  Created by James Richard on 7/13/14.
//  Copyright (c) 2014 James Richard. All rights reserved.
//

import Foundation

/**
    A PreworkerContext provides some control over the work being done within a
    Preworker's work closure. It allows you to handle multi-threading within the closure
    by managing a tally of pending operations, and provides access to a progress
    variable to adjust the progress of the work block.

    A PreworkerContext is passed into every Preworker work closure. This class
    should not be instantiated by anything but a Preworker
*/
public class PreworkerContext<T> {
    /**
        This represents the current progress of the work, as a fraction. It should only be
        set to values 0 to 1.0. Setting outside of that range will cause the value to automatically 
        set within that range (For example, -1.0 will be set to 0, and 3.0 will be set to 1.0)
    
        Changing this value will trigger a progress update. If the Preworker that is using this
        context contains a progress handler, it will be called with the new progress on the
        main queue.
    */
    public var progress: Float {
        get {
            return storedProgress
        }
        
        set {
            storedProgress = max(min(newValue, 1.0), 0.0)
        }
    }
    
    /// The stored value for Progress. This is stored here to allow limits to the values.
    private var storedProgress: Float = 0.0 {
        didSet(newProgress) {
            if let ph = preworker.progressHandler {
                dispatch_async(dispatch_get_main_queue()) {
                    ph(progress: newProgress)
                }
            }
        }
    }
    
    /// The dispatch group that this context will use to wait for pending operations
    private let group = dispatch_group_create()
    
    /// The preworker that this instance is the context for
    private unowned let preworker: Preworker<T>
    
    /// Instantiates a PreworkerContext. This is internal to Preworker and should not be called by clients.
    init(preworker: Preworker<T>) {
        self.preworker = preworker
    }
    
    /**
        Increases the number of pending operations that this context should wait for.
        This call must be balanced by decreasePendingOperations, or the waitForPendingOperations()
        method will never return.
    */
    public func increasePendingOperations() {
        dispatch_group_enter(group)
    }
    
    /**
        Decreases the number of pending operations that this context should wait for.
        This call must balance a previous call to increasePendingOperations. If it is called
        more times than dispatch_group_enter is called, an exception will be thrown by libdispatch.
    */
    public func decreasePendingOperations() {
        dispatch_group_leave(group)
    }
    
    /**
        This method will wait for all pending operations to complete.
    */
    public func waitForPendingOperations() {
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    }
}

/**
    Increases the number of pending operations that context should wait for.
    This call must be balanced by decreasePendingOperations, or the waitForPendingOperations()
    method will never return.
*/
public postfix func ++ <T>(context: PreworkerContext<T>) {
    context.increasePendingOperations()
}

/**
    Decreases the number of pending operations that context should wait for.
    This call must balance a previous call to increasePendingOperations. If it is called
    more times than dispatch_group_enter is called, an exception will be thrown by libdispatch.
*/
public postfix func -- <T>(context: PreworkerContext<T>) {
    context.decreasePendingOperations()
}
