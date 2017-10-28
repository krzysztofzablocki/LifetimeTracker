//
//  DashboardView.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//

import UIKit

struct DashboardViewModel {
    let summary: NSAttributedString
	let sections: [GroupModel]
}

final class DashboardViewController: UIViewController {
    enum State {
        case open
        case closed

        var opposite: State {
            switch self {
            case .open: return .closed
            case .closed: return .open
            }
        }
    }

    enum Edge: Int {
        case top
        case bottom
    }

	class func makeFromNib() -> DashboardViewController {
		let viewController = Bundle(for: self).loadNibNamed("\(self)", owner: nil, options: nil)!.first as! DashboardViewController
		return viewController
	}

    private var state: State = .closed {
        didSet { self.clampDragOffset() }
	}

	fileprivate var sections: [GroupModel] = []
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var summaryLabel: UILabel!
    public var edge: Edge = .bottom

    private let closedHeight: CGFloat = Constants.Layout.Dashboard.headerHeight
    private var originalOffset: CGFloat = 0
    private var dragOffset: CGFloat = 0 {
        didSet { relayout() }
    }
	private var offsetForCloseJumpBack: CGFloat = 0
	private var currentScreenSize: CGSize = CGSize.zero

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

		tableView.register(DashboardTableViewCell.lt_nibInOwnBundle, forCellReuseIdentifier: Constants.Identifier.Reuse.dashboardCell)
		tableView.register(DashboardTableViewHeaderView.lt_nibInOwnBundle, forHeaderFooterViewReuseIdentifier: Constants.Identifier.Reuse.dashboardHeader)

        tableView.scrollsToTop = false

        addPanGestureRecognizer()
        dragOffset = maximumYPosition
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    func update(with vm: DashboardViewModel) {
        summaryLabel?.attributedText = vm.summary

        sections = vm.sections

        tableView.reloadData()
        tableView.layoutIfNeeded()

		// Update the drag offset as the height might increase. The offset has to be decreased in this case
		if (dragOffset + heightToShow) > maximumHeight {
			dragOffset = maximumHeight - heightToShow
			offsetForCloseJumpBack = maximumHeight - closedHeight
		}

        relayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

		if currentScreenSize != UIScreen.main.bounds.size {
			dragOffset = maximumYPosition
			offsetForCloseJumpBack = maximumHeight - closedHeight
		}
		currentScreenSize = UIScreen.main.bounds.size

        relayout()
    }

    // MARK: - Layout

    private var heightToShow: CGFloat {
		var height = CGFloat(0)
		switch state {
        case .closed:
            height = closedHeight
        case .open:
            height = heightToFitTableView
        }
		return min(maximumHeight, height)
    }

	private var maximumHeight: CGFloat {
		return UIScreen.main.bounds.height
	}

    private var maximumYPosition: CGFloat {
        return maximumHeight - heightToShow
    }

    private var heightToFitTableView: CGFloat {
        let size = tableView.contentSize
        return max(Constants.Layout.Dashboard.minTotalHeight, size.height + closedHeight)
    }

    private var layoutWidth: CGFloat { return UIScreen.main.bounds.width }

    private func relayout() {
        guard let window = view.window else { return }

		// Prevent black areas during device orientation
		window.clipsToBounds = true
		window.translatesAutoresizingMaskIntoConstraints = true
		window.frame = CGRect(x: 0, y: dragOffset, width: UIScreen.main.bounds.width, height: heightToShow)
        view.layoutIfNeeded()
    }

    // MARK: - Expand / collapse

    @IBAction private func expandTapped(_ sender: UIButton) {
		if state == .closed {
			offsetForCloseJumpBack = dragOffset
		}
		state = state.opposite

		if state == .closed && offsetForCloseJumpBack == maximumYPosition {
			dragOffset = offsetForCloseJumpBack
		}

        UIView.animateKeyframes(withDuration: Constants.Layout.animationDuration, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced] , animations: {
            self.relayout()
        }, completion: nil)
    }

    // MARK: Panning

    func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(toolbarPanned))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func toolbarPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            originalOffset = dragOffset
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            dragOffset = originalOffset + translation.y
            clampDragOffset()
			if state == .open {
				offsetForCloseJumpBack = dragOffset
			}
        default: break
        }
    }

    func clampDragOffset() {
        dragOffset = min(maximumYPosition, dragOffset)
    }
}

extension DashboardViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard section < sections.count else {
			return 0
		}

		return sections[section].entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.Reuse.dashboardCell, for: indexPath) as? DashboardTableViewCell else {
			return UITableViewCell()
		}

		let group =  sections[indexPath.section]
		let entry = group.entries[indexPath.row]
		cell.setup(groupColor: group.color, classColor: entry.color, description: entry.description)

        return cell
    }

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return Constants.Layout.Dashboard.cellHeight
	}
}

extension DashboardViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		guard section < sections.count,
			let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.Identifier.Reuse.dashboardHeader) as? DashboardTableViewHeaderView else {
			return nil
		}

		let section = sections[section]
		headerView.setup(color: section.color, title: section.title)

		return headerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return Constants.Layout.Dashboard.sectionHeaderHeight
	}
}
