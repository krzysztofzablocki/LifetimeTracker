//
//  LifetimeTracker.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import Foundation

public struct LifetimeConfiguration {
	public var maxCount: Int
	public var groupName: String? = nil
	public var groupMaxCount: Int? = nil

	internal var instanceName: String = ""
	internal var pointerString: String = ""

	public init(maxCount: Int) {
		self.maxCount = maxCount
	}

	public init(maxCount: Int, groupName: String) {
		self.maxCount = maxCount
		self.groupName = groupName
	}

	public init(maxCount: Int, groupName: String, overrideGroupMaxCount: Int) {
		self.maxCount = maxCount
		self.groupName = groupName
		self.groupMaxCount = overrideGroupMaxCount
	}

	internal static func makeCompleteConfiguration(with instance: LifetimeTrackable) -> LifetimeConfiguration {
		let instanceType = type(of: instance)
		var configuration = instanceType.lifetimeConfiguration
		configuration.instanceName = String(describing: instanceType)
		configuration.pointerString = "\(Unmanaged<AnyObject>.passUnretained(instance as AnyObject).toOpaque())"
		return configuration
	}
}


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
	public typealias UpdateClosure = (_ trackedGroups: [String: LifetimeTracker.EntriesGroup]) -> Void
    public fileprivate(set) static var instance: LifetimeTracker?
    private let lock = NSRecursiveLock()

    private var trackedGroups = [String: EntriesGroup]()

	enum LifetimeState {
		case valid
		case leaky
	}

    public final class Entry {
        let maxCount: Int
        let name: String
		fileprivate(set) var count: Int
		fileprivate(set) var pointers: Set<String>

		init(name: String, maxCount: Int) {
			self.maxCount = maxCount
			self.name = name
            self.count = 0
            self.pointers = Set<String>()
        }

		func update(pointerString pointer: String, for countDelta: Int) {
			count += countDelta
			if countDelta > 0 {
				pointers.insert(pointer)
			} else {
				pointers.remove(pointer)
			}
		}

        var lifetimeState: LifetimeState {
			return count > maxCount ? .leaky : .valid
        }
    }

	public final class EntriesGroup {
		var maxCount: Int = 0
		var name: String? = nil
		fileprivate(set) var count: Int = 0
		fileprivate(set) var entries = [String: Entry]()
		private var usedMaxCountOverride = false

		init(name: String) {
			if name != "lifetimetracker.nogroup.identifier" {
				self.name = name
			}
		}

		var lifetimeState: LifetimeState {
			// Mark the group as leaky if the count per group highter than it's max count
			guard count <= maxCount else {
				return .leaky
			}
			// If the group total count isn't leaky, check if at least one entry is leaky
			let leakyEntries = entries.filter { (key: String, entry: LifetimeTracker.Entry) -> Bool in
				return entry.lifetimeState == .leaky
			}
			return leakyEntries.isEmpty ? .valid : .leaky
		}

		func updateEntry(_ configuration: LifetimeConfiguration, with countDelta: Int) {

			let entryName = configuration.instanceName
			let didEntryExistBefore = entries[entryName] != nil

			let entry = entries[entryName] ?? Entry(name: entryName, maxCount:configuration.maxCount)
			entry.update(pointerString: configuration.pointerString, for: countDelta)
			entries[entryName] = entry

			count += countDelta

			if let groupMaxCount = configuration.groupMaxCount {
				usedMaxCountOverride = true
				maxCount = groupMaxCount
			} else if !usedMaxCountOverride && !didEntryExistBefore {
				maxCount += configuration.maxCount
			}
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

	fileprivate func track(_ instance: LifetimeTrackable, file: String = #file) {
        lock.lock()
        defer {
            self.onUpdate(self.trackedGroups)
            lock.unlock()
        }

		let instanceType = type(of: instance)
		var configuration = instanceType.lifetimeConfiguration
		configuration.instanceName = String(describing: instanceType)
		configuration.pointerString = "\(Unmanaged<AnyObject>.passUnretained(instance as AnyObject).toOpaque())"

		func update(_ configuration: LifetimeConfiguration, with countDelta: Int) {

			let groupName = configuration.groupName ?? "lifetimetracker.nogroup.identifier"

			let group = self.trackedGroups[groupName] ?? EntriesGroup(name: groupName)
			group.updateEntry(configuration, with: countDelta)

			self.trackedGroups[groupName] = group
        }

		update(configuration, with: +1)

        onDealloc(of: instance) {
            self.lock.lock()
            defer {
                self.onUpdate(self.trackedGroups)
                self.lock.unlock()
            }

			update(configuration, with: -1)
        }
    }

    public var debugDescription: String {
        lock.lock()
        defer {
            lock.unlock()
        }

        let keys = trackedGroups.keys.sorted(by: >)
        return keys.reduce("") { acc, key in
            if let group = trackedGroups[key], group.lifetimeState == .leaky {
                return acc + "\(group.name): \(group.count)\n"
            }

            return acc
        }
    }
}
