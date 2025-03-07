//
//  SettingsManager.swift
//  LifetimeTracker
//
//  Created by Thanh Duc Do on 23.08.18.
//  Copyright © 2018 LifetimeTracker. All rights reserved.
//

import UIKit

struct SettingsManager {

    // On iPhone, this has no effect if the alert has preferredStyle: .actionSheet.
    // On iPad, this creates a root-less popover which mimics the appearance of an actionSheet
    // without requiring a sourceView or barButton.
    private static func createRootlessPopover(centeredOn view: UIView, alert: UIAlertController) {
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = view
            popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
    }

	static func showSettingsActionSheet(on viewController: UIViewController, completionHandler: @escaping (HideOption) -> Void) {
        let alert = UIAlertController(title: "settings".lt_localized, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "settings.hide.title".lt_localized, style: .default, handler: { (action: UIAlertAction) in
            let alert = UIAlertController(title: "settings.hide.sheet.title".lt_localized, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "settings.hide.sheet.untilMoreIssue".lt_localized, style: .default, handler: { (action: UIAlertAction) in
                completionHandler(.untilMoreIssue)
            }))
            alert.addAction(UIAlertAction(title: "settings.hide.sheet.untilNewType".lt_localized, style: .default, handler: { (action: UIAlertAction) in
                completionHandler(.untilNewIssueType)
            }))
            alert.addAction(UIAlertAction(title: "settings.hide.sheet.untilRestart".lt_localized, style: .default, handler: { (action: UIAlertAction) in
                completionHandler(.always)
            }))
            alert.addAction(UIAlertAction(title: "settings.cancel".lt_localized, style: .cancel, handler: { (action: UIAlertAction) in
                completionHandler(.none)
            }))
            createRootlessPopover(centeredOn: viewController.view, alert: alert)
            viewController.present(alert, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "settings.cancel".lt_localized, style: .cancel, handler: { (action: UIAlertAction) in
            completionHandler(.none)
        }))

        createRootlessPopover(centeredOn: viewController.view, alert: alert)

        viewController.present(alert, animated: true, completion: nil)
    }
}
