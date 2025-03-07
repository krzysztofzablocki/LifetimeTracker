//
//  DashboardTableViewController.swift
//  LifetimeTracker-iOS
//
//  Created by Hans Seiffert on 18.03.18.
//  Copyright © 2018 LifetimeTracker. All rights reserved.
//

import UIKit

class DashboardTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    
    fileprivate var dashboardViewModel = BarDashboardViewModel()
    
    var contentSize: CGSize {
        return tableView?.contentSize ?? CGSize.zero
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(DashboardTableViewHeaderView.lt_nibInOwnBundle, forHeaderFooterViewReuseIdentifier: Constants.Identifier.Reuse.dashboardHeader)
        tableView?.register(DashboardTableViewCell.lt_nibInOwnBundle, forCellReuseIdentifier: Constants.Identifier.Reuse.dashboardCell)
        
        tableView?.scrollsToTop = false
    }
    
    func update(dashboardViewModel: BarDashboardViewModel) {
        self.dashboardViewModel = dashboardViewModel
        
        tableView?.reloadData()
        tableView?.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource

extension DashboardTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dashboardViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < dashboardViewModel.sections.count else {
            return 0
        }
        
        return dashboardViewModel.sections[section].entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.Reuse.dashboardCell, for: indexPath) as? DashboardTableViewCell else {
            return UITableViewCell()
        }
        
        let group =  dashboardViewModel.sections[indexPath.section]
        let entry = group.entries[indexPath.row]
        cell.setup(groupColor: group.color, classColor: entry.color, description: entry.description)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Layout.Dashboard.cellHeight
    }
}

// MARK: - UITableViewDelegate

extension DashboardTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < dashboardViewModel.sections.count,
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.Reuse.dashboardHeader) as? DashboardTableViewHeaderView else {
                return nil
        }
        
        let section = dashboardViewModel.sections[section]
        headerView.setup(color: section.color, title: section.title)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.Layout.Dashboard.sectionHeaderHeight
    }
}
