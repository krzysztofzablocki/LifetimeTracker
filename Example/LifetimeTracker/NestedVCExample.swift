//
//  NestedVCExample.swift
//  Example
//
//  Created by Hans Seiffert on 26.03.19.
//  Copyright © 2019 LifetimeTracker. All rights reserved.
//

import UIKit
import LifetimeTracker

class BaseViewController: UIViewController, LifetimeTrackable {
	
	static var lifetimeConfiguration: LifetimeConfiguration {
		return LifetimeConfiguration(maxCount: 2)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		trackLifetime()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		trackLifetime()
	}
}

class ChildAViewController: BaseViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .yellow
	}
}

class ChildBViewController: BaseViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .blue
	}
}
