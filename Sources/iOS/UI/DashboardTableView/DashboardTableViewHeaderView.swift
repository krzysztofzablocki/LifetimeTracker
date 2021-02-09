//
//  DashboardTableViewHeaderView.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 21.10.17.
//

import UIKit

class DashboardTableViewHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private weak var indicatorView: UIView!
    @IBOutlet private weak var groupNameLabel: UILabel!
    
    class var nib: UINib {
        lt_nibInOwnBundle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indicatorView.backgroundColor = .clear
        groupNameLabel.text = nil
    }
    
    func setup(color: UIColor, title: String) {
        indicatorView.backgroundColor = color
        groupNameLabel.text = title
    }
}
