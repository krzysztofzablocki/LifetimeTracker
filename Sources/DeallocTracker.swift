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
    var tracker = DeallocTracker(onDealloc: closure)
    objc_setAssociatedObject(owner, &tracker, tracker, .OBJC_ASSOCIATION_RETAIN)
}
