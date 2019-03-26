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
		return LifetimeConfiguration(maxCount: self.maxCount, groupName: self.groupName)
	}
	
	class var maxCount: Int {
		return 1
	}
	
	class var groupName: String {
		return "Base"
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
	
	override class var groupName: String {
		return "ChildA"
	}
	
	override class var maxCount: Int {
		return 2
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .yellow
	}
}

class ChildBViewController: BaseViewController {
	
	override class var groupName: String {
		return "ChildB"
	}
	
	override class var maxCount: Int {
		return 2
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .blue
	}
}
