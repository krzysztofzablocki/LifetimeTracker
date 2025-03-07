//
//  LifetimeTrackerListViewController.swift
//  LifetimeTracker-iOS
//
//  Created by Hans Seiffert on 18.03.18.
//  Copyright © 2018 LifetimeTracker. All rights reserved.
//

import UIKit

protocol PopoverViewControllerDelegate: AnyObject {
    func dismissPopoverViewController()
    func changeHideOption(for hideOption: HideOption)
}

class LifetimeTrackerListViewController: UIViewController {
    
    weak var delegate: PopoverViewControllerDelegate?
    
    weak var tableViewController: DashboardTableViewController?
    
    var dashboardViewModel = BarDashboardViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        delegate?.dismissPopoverViewController()
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        SettingsManager.showSettingsActionSheet(on: self, completionHandler: { [weak self] (selectedOption: HideOption) in
            self?.delegate?.changeHideOption(for: selectedOption)
        })
    }

    func update(dashboardViewModel: BarDashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
        
        title = "popover.dasboard.title".lt_localized
        
        tableViewController?.update(dashboardViewModel: dashboardViewModel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.embedDashboardTableView.identifier {
            tableViewController = segue.destination as? DashboardTableViewController
            tableViewController?.update(dashboardViewModel: dashboardViewModel)
        }
    }
}
