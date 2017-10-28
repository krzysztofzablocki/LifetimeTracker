//
//  DashboardTableViewCell.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 21.10.17.
//

import UIKit

class DashboardTableViewCell: UITableViewCell {

	@IBOutlet private weak var groupIndicatorView: UIView!
	@IBOutlet private weak var classIndicatorView: UIView!
	@IBOutlet private weak var descriptionLabel: UILabel!

	class var nib: UINib {
		return UINib(nibName: "\(self)", bundle: Bundle(for: self))
	}

	override func prepareForReuse() {
		groupIndicatorView.backgroundColor = .clear
		classIndicatorView.backgroundColor = .clear
		descriptionLabel.text = nil
	}

	func setup(groupColor: UIColor, classColor: UIColor, description: String) {
		groupIndicatorView.backgroundColor = groupColor
		classIndicatorView.backgroundColor = classColor
		descriptionLabel.text = description
	}
}
