//
//  Constants.swift
//  LifetimeTracker
//
//  Created by Hans Seiffert on 23.10.17.
//

import Foundation

internal struct Constants {

	struct Identifier {

		struct EntryGroup {
			static let none = "lifetimetracker.nogroup.identifier"
		}

		struct Reuse {
			static let dashboardCell = "lifetimeTrackerDashboardTableViewCell"
			static let dashboardHeader = "lifetimeTrackerDashboardHeaderViewCell"
		}
	}

	struct Layout {
		static let animationDuration: TimeInterval = 0.3

		struct Dashboard {
			static let headerHeight: CGFloat = 44
			static let cellHeight: CGFloat = 44
			static let minTotalHeight: CGFloat = headerHeight + cellHeight
			static let sectionHeaderHeight: CGFloat = 30
		}
	}
}
