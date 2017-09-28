//
//  LifetimeTracker+DashboardView.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//

import UIKit

fileprivate extension String {
    func attributed(_ attributes: [String: Any] = [:]) -> NSAttributedString {
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

public final class LifetimeTrackerDashboardIntegration {

    private lazy var vc: DashboardViewController = {
        let bundle = Bundle(for: DashboardViewController.self)
        let vc =
            bundle.loadNibNamed("DashboardViewController", owner: nil, options: nil)!.first as! DashboardViewController
        return vc
    }()

    private lazy var window: UIWindow = {
        let window = UIWindow(frame: .zero)
        window.windowLevel = UIWindowLevelStatusBar
        window.rootViewController = self.vc
        return window
    }()

    public init() {}

    public func refreshUI(counts: [String: LifetimeTracker.Entry], fullEntries: [String: LifetimeTracker.Entry]) {
        window.isHidden = false
        let vm = DashboardViewModel(summary: summary(from: counts), entries: entries(from: fullEntries))
        vc.update(with: vm)
    }

    private func summary(from counts: [String: LifetimeTracker.Entry]) -> NSAttributedString {
        let keys = counts.keys.sorted(by: >)
        let list = keys.filter { key in
                return counts[key]?.shouldDisplay == true
            }.map { key in
                return "\(counts[key]!.count) \(key)"
            }.joined(separator: ", ")

        if list.isEmpty {
            return "No issues detected".attributed([
                NSForegroundColorAttributeName: UIColor.green
                ])
        }

        return ("Detected: ").attributed([
            NSForegroundColorAttributeName: UIColor.red
            ]) + list.attributed()
    }

    private func entries(from fullEntries: [String: LifetimeTracker.Entry]) -> [String] {
        return fullEntries
            .sorted { (left, right) -> Bool in
                left.value.count < right.value.count
            }
            .map { (key, value) -> String in
                return "\(value.count) \(value.fullName): \(value.pointers.joined(separator: ", "))"
        }
    }
}
