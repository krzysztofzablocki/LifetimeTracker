//
//  Constants.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 09.11.17.
//  Copyright © 2017 LifetimeTracker. All rights reserved.
//

import UIKit

extension Constants {
    
    struct Layout {
        static let animationDuration: TimeInterval = 0.3
        
        struct Dashboard {
            static let headerHeight: CGFloat = 44.0
            static let cellHeight: CGFloat = 44
            static let minTotalHeight: CGFloat = headerHeight + cellHeight
            static let sectionHeaderHeight: CGFloat = 30
        }
    }
    
    enum Segue {
        case embedDashboardTableView
        
        var identifier: String {
            switch self {
            case .embedDashboardTableView: return "embedDashboardTableViewController"
            }
        }
    }
    
    enum Storyboard {
        case circularDashboard
        case barDashboard
        
        var name: String {
            switch self {
            case .circularDashboard: return "CircularDashboard"
            case .barDashboard: return "BarDashboard"
            }
        }
    }
}
