//
//  BarDashboardViewController.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//

import UIKit

struct BarDashboardViewModel {
    let leaksCount: Int
    let summary: NSAttributedString
    let sections: [GroupModel]
    let textColorForNoIssues: UIColor
    let textColorForLeakDetected: UIColor

    init(
      leaksCount: Int = 0,
      summary: NSAttributedString = NSAttributedString(),
      sections: [GroupModel] = [],
      textColorForNoIssues: UIColor = .systemGreen,
      textColorForLeakDetected: UIColor = .systemRed
    ) {
        self.leaksCount = leaksCount
        self.summary = summary
        self.sections = sections
        self.textColorForNoIssues = textColorForNoIssues
        self.textColorForLeakDetected = textColorForLeakDetected
    }
}

final class BarDashboardViewController: UIViewController, LifetimeTrackerViewable {

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

    class func makeFromNib() -> UIViewController & LifetimeTrackerViewable {
        let storyboard = UIStoryboard(name: Constants.Storyboard.barDashboard.name, bundle: .resolvedBundle)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! BarDashboardViewController
    }

    private var state: State = .closed {
        didSet { clampDragOffset() }
    }

    private var hideOption: HideOption = .none {
        didSet {
            if hideOption != .none {
                view.isHidden = true
            }
        }
    }

    fileprivate var dashboardViewModel = BarDashboardViewModel()
    @IBOutlet private var tableViewController: DashboardTableViewController?
    @IBOutlet private var summaryLabel: UILabel?
    @IBOutlet private weak var barView: UIView!
    @IBOutlet private weak var headerView: UIView?

    public var edge: Edge = .bottom

    private let closedHeight: CGFloat = Constants.Layout.Dashboard.headerHeight
    private var originalOffset: CGFloat = 0
    private var dragOffset: CGFloat = 0 {
        didSet { relayout() }
    }
    private var offsetForCloseJumpBack: CGFloat = 0
    private var currentScreenSize: CGSize = CGSize.zero
    private var fullScreen: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        addTapGestureRecognizer()
        addPanGestureRecognizer()
        dragOffset = maximumYPosition
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    func update(with vm: BarDashboardViewModel) {
        summaryLabel?.attributedText = vm.summary

        if hideOption.shouldUIBeShown(oldModel: dashboardViewModel, newModel: vm) {
            view.isHidden = false
            hideOption = .none
        }

        dashboardViewModel = vm

        tableViewController?.update(dashboardViewModel: vm)

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.embedDashboardTableView.identifier {
            tableViewController = segue.destination as? DashboardTableViewController
            tableViewController?.update(dashboardViewModel: dashboardViewModel)
        }
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

    private var minimumYPosition: CGFloat {
        if #available(iOS 11, *) {
            return view.safeAreaInsets.top
        } else {
            return 0.0
        }
    }

    private var maximumHeight: CGFloat {
        if #available(iOS 11, *) {
            return UIScreen.main.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        } else {
            return UIScreen.main.bounds.height
        }
    }

    private var maximumYPosition: CGFloat {
        if #available(iOS 11, *) {
            return maximumHeight - heightToShow - view.safeAreaInsets.bottom + view.safeAreaInsets.top
        } else {
            return maximumHeight - heightToShow
        }
    }

    private var heightToFitTableView: CGFloat {
        let size = tableViewController?.contentSize ?? CGSize.zero
        return max(Constants.Layout.Dashboard.minTotalHeight, size.height + closedHeight)
    }

    private var layoutWidth: CGFloat { return UIScreen.main.bounds.width }

    private func relayout() {
        guard let window = view.window else { return }

        // Prevent black areas during device orientation
        window.clipsToBounds = true
        window.translatesAutoresizingMaskIntoConstraints = true
        window.frame = CGRect(x: 0, y: fullScreen ? 0 : dragOffset, width: UIScreen.main.bounds.width, height: fullScreen ? UIScreen.main.bounds.height : heightToShow)
        view.layoutIfNeeded()
    }

    // MARK: - Expand / collapse

    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        headerView?.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func headerTapped() {
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

    // MARK: - Settings

    @IBAction private func settingsButtonTapped(_ sender: UIButton) {
        guard let originalWindowFrame = view.window?.frame.origin else {
            return
        }
        let originalBarFrame = barView.frame
        barView.translatesAutoresizingMaskIntoConstraints = true
        barView.frame = CGRect(x: originalWindowFrame.x, y: originalWindowFrame.y, width: originalBarFrame.width, height: originalBarFrame.height)
        fullScreen = true
        relayout()
        SettingsManager.showSettingsActionSheet(on: self, completionHandler: { [weak self] (selectedOption: HideOption) in
            self?.hideOption = selectedOption
            self?.barView.translatesAutoresizingMaskIntoConstraints = false
            self?.fullScreen = false
            self?.relayout()
        })
    }

    // MARK: Panning

    func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(toolbarPanned))
        view.addGestureRecognizer(panGestureRecognizer)
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
        if dragOffset < minimumYPosition {
            dragOffset = minimumYPosition
        } else if dragOffset > maximumYPosition {
            dragOffset = maximumYPosition
        }
    }
}
