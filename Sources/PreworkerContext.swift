//
//  PreworkerContext.swift
//  Preworker
//
//  Created by James Richard on 7/13/14.
//  Copyright (c) 2014 James Richard. All rights reserved.
//

import Foundation

public class PreworkerContext<T> {
    public var progress: Float = 0.0 {
        didSet(newProgress) {
            if let ph = preworker.progressHandler {
                dispatch_async(dispatch_get_main_queue()) {
                    ph(progress: newProgress)
                }
            }
        }
    }
    
    private let group = dispatch_group_create()
    private unowned let preworker: Preworker<T>
    
    init(preworker: Preworker<T>) {
        self.preworker = preworker
    }
    
    public func increasePendingOperations() {
        dispatch_group_enter(group)
    }
    
    public func decreasePendingOperations() {
        dispatch_group_leave(group)
    }
    
    public func waitForPendingOperations() {
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
    }
}

public postfix func ++ <T>(context: PreworkerContext<T>) {
    context.increasePendingOperations()
}

public postfix func -- <T>(context: PreworkerContext<T>) {
    context.decreasePendingOperations()
}
