//
//  DeallocTracker.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

fileprivate final class DeallocTracker {
    let onDealloc: () -> Void
    
    init(onDealloc: @escaping () -> Void) {
        self.onDealloc = onDealloc
    }
    
    deinit {
        onDealloc()
    }
}

/// Executes action upon deallocation of owner
///
/// - Parameters:
///   - owner: Owner to track.
///   - closure: Closure to execute.
internal func onDealloc(of owner: Any, closure: @escaping () -> Void) {
    let tracker = DeallocTracker(onDealloc: closure)
    objc_setAssociatedObject(owner, getID(tracker), tracker, .OBJC_ASSOCIATION_RETAIN)
}

// https://github.com/atrick/swift-evolution/blob/diagnose-implicit-raw-bitwise/proposals/nnnn-implicit-raw-bitwise-conversion.md#associated-object-string-keys
private func getID(_ object: AnyObject) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(object).toOpaque())
}
