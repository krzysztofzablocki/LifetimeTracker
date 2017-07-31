//
//  ViewController.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 07/31/2017.
//  Copyright (c) 2017 Krzysztof Zablocki. All rights reserved.
//

import UIKit
import LifetimeTracker

var leakStorage = [AnyObject]()

class ViewController: UIViewController, LifetimeTrackable {
    static var lifetimeConfiguration: LifetimeConfiguration = (identifier: "VC", maxCount: 1)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        trackLifetime()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        trackLifetime()
    }

    @IBAction func createLeak(_ sender: Any) {
        leakStorage.append(ViewController())
    }

    @IBAction func removeLeaks(_ sender: Any) {
        leakStorage.removeAll()
    }
}

