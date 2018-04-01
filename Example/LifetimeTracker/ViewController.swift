//
//  ViewController.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 07/31/2017.
//  Copyright (c) 2017 Krzysztof Zablocki. All rights reserved.
//

import UIKit
import LifetimeTracker

// MARK: - DetailItem -

class DetailItem: LifetimeTrackable {

    class var lifetimeConfiguration: LifetimeConfiguration {
        // There can be up to three 3 instances from the class. But only three in total including the subclasses
        return LifetimeConfiguration(maxCount: 3, groupName: "Detail Item", groupMaxCount: 3)
    }

    init() {
        self.trackLifetime()
    }
}

// MARK: - DetailItem Subclasses

class AudtioDetailItem: DetailItem { }
class ImageDetailItem: DetailItem { }
class VideoDetailItem: DetailItem {

    override class var lifetimeConfiguration: LifetimeConfiguration {
        // There should only be one video item as the memory usage is too high
        let configuration = super.lifetimeConfiguration
        configuration.maxCount = 1
        return configuration
    }
}

// MARK: - ViewController -

var leakStorage = [AnyObject]()

class ViewController: UIViewController, LifetimeTrackable {
    
    static var lifetimeConfiguration = LifetimeConfiguration(maxCount: 1, groupName: "VC")

    // MARK: - Initialization

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        trackLifetime()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        trackLifetime()
    }

    // MARK: - IBActions

    @IBAction func createLeak(_ sender: Any) {
        leakStorage.append(ViewController())

        leakStorage.append(AudtioDetailItem())
        leakStorage.append(ImageDetailItem())
        leakStorage.append(VideoDetailItem())
    }

    @IBAction func removeLeaks(_ sender: Any) {
        leakStorage.removeAll()
    }
}
