//
//  LifetimeTracker+DashboardView.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//

import UIKit

fileprivate extension String {
    #if swift(>=4.0)
    typealias AttributedStringKey = NSAttributedStringKey
    static let foregroundColorAttributeName = NSAttributedStringKey.foregroundColor
    #else
    typealias AttributedStringKey = String
    static let foregroundColorAttributeName = NSForegroundColorAttributeName
    #endif

    func attributed(_ attributes: [AttributedStringKey: Any] = [:]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attributes)
    }
}

extension NSAttributedString {
    fileprivate static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: left)
        result.append(right)
        return result
    }
}

typealias EntryModel = (color: UIColor, description: String)
typealias GroupModel = (color: UIColor, title: String, entries: [EntryModel])

public final class LifetimeTrackerDashboardIntegration {

    private lazy var vc: DashboardViewController = {
        return DashboardViewController.makeFromNib()
    }()

    private lazy var window: UIWindow = {
        let window = UIWindow(frame: .zero)
        window.windowLevel = UIWindowLevelStatusBar
		window.frame =  UIScreen.main.bounds
        window.rootViewController = self.vc
        return window
    }()

    public enum Visibility {
        case alwaysHidden
        case alwaysVisible
        case visibleWithIssuesDetected

        func windowIsHidden(hasIssuesToDisplay: Bool) -> Bool {
            switch self {
            case .alwaysHidden: return true
            case .alwaysVisible: return false
            case .visibleWithIssuesDetected: return !hasIssuesToDisplay
            }
        }
    }

    public var visibility: Visibility

    public init(visibility: Visibility = .alwaysVisible) {
        self.visibility = visibility
    }

	public func refreshUI(trackedGroups: [String: LifetimeTracker.EntriesGroup]) {
        DispatchQueue.main.async {
            self.window.isHidden = self.visibility.windowIsHidden(hasIssuesToDisplay: self.hasIssuesToDisplay(from: trackedGroups))
			let vm = DashboardViewModel(summary: self.summary(from: trackedGroups), sections: self.entries(from: trackedGroups))
            self.vc.update(with: vm)
        }
    }

    private func summary(from trackedGroups: [String: LifetimeTracker.EntriesGroup]) -> NSAttributedString {
        let groupNames = trackedGroups.keys.sorted(by: >)
        let leakyGroupSummaries = groupNames.filter { groupName in
                return trackedGroups[groupName]?.lifetimeState == .leaky
            }.map { groupName in
				let group = trackedGroups[groupName]!
				let maxCountString = group.maxCount == Int.max ? "macCount.notSpecified".lt_localized : "\(group.maxCount)"
                return "\(group.name ?? "dashboard.sectionHeader.title.noGroup".lt_localized) (\(group.count)/\(maxCountString))"
            }.joined(separator: ", ")

        if leakyGroupSummaries.isEmpty {
            return "dashboard.header.issue.description.noIssues".lt_localized.attributed([
                String.foregroundColorAttributeName: UIColor.green
                ])
        }

        return ("\("dashboard.header.issue.description.leakDetected".lt_localized): ").attributed([
            String.foregroundColorAttributeName: UIColor.red
            ]) + leakyGroupSummaries.attributed()
    }

	private func entries(from trackedGroups: [String: LifetimeTracker.EntriesGroup]) -> [GroupModel] {
		var sections = [GroupModel]()
        let filteredGroups = trackedGroups.filter { (_, group: LifetimeTracker.EntriesGroup) -> Bool in
            group.count > 0
        }
        filteredGroups
			.sorted { (lhs: (key: String, value: LifetimeTracker.EntriesGroup), rhs: (key: String, value: LifetimeTracker.EntriesGroup)) -> Bool in
                return (lhs.value.maxCount - lhs.value.count) < (rhs.value.maxCount - rhs.value.count)
            }
			.forEach { (groupName: String, group: LifetimeTracker.EntriesGroup) in
				var groupColor: UIColor
				switch group.lifetimeState {
				case .valid: groupColor = .green
				case .leaky: groupColor = .red
				}
				let groupMaxCountString = group.maxCount == Int.max ? "macCount.notSpecified".lt_localized : "\(group.maxCount)"
				let title = "\(group.name ?? "dashboard.sectionHeader.title.noGroup".lt_localized) (\(group.count)/\(groupMaxCountString))"
				var rows = [EntryModel]()
				group.entries.sorted { (lhs: (key: String, value: LifetimeTracker.Entry), rhs: (key: String, value: LifetimeTracker.Entry)) -> Bool in
					lhs.value.count > rhs.value.count
				}
				.filter { (_, entry: LifetimeTracker.Entry) -> Bool in
					entry.count > 0
				}.forEach { (_, entry: LifetimeTracker.Entry) in
					var color: UIColor
					switch entry.lifetimeState {
					case .valid: color = .green
					case .leaky: color = .red
					}
					let entryMaxCountString = entry.maxCount == Int.max ? "macCount.notSpecified".lt_localized : "\(entry.maxCount)"
					let description = "\(entry.name) (\(entry.count)/\(entryMaxCountString)):\n\(entry.pointers.joined(separator: ", "))"
					rows.append((color: color, description: description))
				}
				sections.append((color: groupColor, title: title, entries: rows))
			}
		return sections
	}

	func hasIssuesToDisplay(from trackedGroups: [String: LifetimeTracker.EntriesGroup]) -> Bool {
		let aDetectedIssue = trackedGroups.keys.first { trackedGroups[$0]?.lifetimeState == .leaky }
		return aDetectedIssue != nil
	}
}
