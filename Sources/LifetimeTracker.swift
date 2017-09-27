//
//  LifetimeTracker.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

/// Identifier to use in summary displays and count of items allowed to be alive at the same time
public typealias LifetimeConfiguration = (identifier: String, maxCount: Int)

/// Defines a type that can have its lifetime tracked
public protocol LifetimeTrackable: class {

    /// Configuration for lifetime tracking, contains identifier and leak classifier
    static var lifetimeConfiguration: LifetimeConfiguration { get }

    /// Starts tracking lifetime, should be called in each initializer
    func trackLifetime()
}

public extension LifetimeTrackable {
    func trackLifetime() {
        LifetimeTracker.instance?.track(self)
    }
}

public final class LifetimeTracker: CustomDebugStringConvertible {
    public typealias UpdateClosure = (_ counts: [String: Entry], _ fullEntries: [String: Entry]) -> Void
    public fileprivate(set) static var instance: LifetimeTracker?
    private let lock = NSRecursiveLock()

    ///! aggregated by identifier
    private var counts = [String: Entry]()
    private var fullEntries = [String: Entry]()

    public final class Entry {
        fileprivate(set) var count: Int
        fileprivate(set) var pointers: Set<String>
        let identifier: String
        let maxCount: Int
        let fullName: String

        init(configuration: LifetimeConfiguration, fullName: String) {
            self.maxCount = configuration.maxCount
            self.identifier = configuration.identifier
            self.fullName = fullName
            self.count = 0
            self.pointers = Set<String>()
        }

        var shouldDisplay: Bool {
            return count > maxCount
        }
    }

    public static func setup(onUpdate: @escaping UpdateClosure) {
        assert(instance == nil)
        instance = LifetimeTracker(onUpdate: onUpdate)
    }

    private let onUpdate: UpdateClosure
    private init(onUpdate: @escaping UpdateClosure) {
        self.onUpdate = onUpdate
    }

    fileprivate func track(_ instance: LifetimeTrackable) {
        lock.lock()
        defer {
            self.onUpdate(self.counts, self.fullEntries)
            lock.unlock()
        }

        let configuration = type(of: instance).lifetimeConfiguration
        let name = configuration.identifier
        let fullName = String(describing: type(of: instance))
        let pointer = "\(Unmanaged<AnyObject>.passUnretained(instance as AnyObject).toOpaque())"

        func update(_ name: String, in container: inout [String: Entry], count: Int = +1) {
            let existing = container[name] ?? Entry(configuration: configuration, fullName: fullName)
            existing.count += count
            container[name] = existing

            if count > 0 {
                container[name]?.pointers.insert(pointer)
            } else {
                container[name]?.pointers.remove(pointer)
            }
        }

        update(name, in: &self.counts)
        update(fullName, in: &self.fullEntries)

        onDealloc(of: instance) {
            self.lock.lock()
            defer {
                self.onUpdate(self.counts, self.fullEntries)
                self.lock.unlock()
            }

            update(name, in: &self.counts, count: -1)
            update(fullName, in: &self.fullEntries, count: -1)
        }
    }

    public var debugDescription: String {
        lock.lock()
        defer {
            lock.unlock()
        }

        let keys = fullEntries.keys.sorted(by: >)
        return keys.reduce("") { acc, key in
            if let value = fullEntries[key], value.shouldDisplay {
                return acc + "\(value.fullName): \(value.count)\n"
            }

            return acc
        }
    }
}
