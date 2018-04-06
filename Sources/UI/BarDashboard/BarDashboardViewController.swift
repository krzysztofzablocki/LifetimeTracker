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
    
    init(leaksCount: Int = 0, summary: NSAttributedString = NSAttributedString(), sections: [GroupModel] = []) {
        self.leaksCount = leaksCount
        self.summary = summary
        self.sections = sections
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
        let storyboard = UIStoryboard(name: Constants.Storyboard.barDashbaord.name, bundle: Bundle(for: self))
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! BarDashboardViewController
    }
    
    private var state: State = .closed {
        didSet { clampDragOffset() }
    }
    
    fileprivate var dashboardViewModel = BarDashboardViewModel()
    @IBOutlet private var tableViewController: DashboardTableViewController?
    @IBOutlet private var summaryLabel: UILabel?
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
        
        addPanGestureRecognizer()
        dragOffset = maximumYPosition
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    func update(with vm: BarDashboardViewModel) {
        summaryLabel?.attributedText = vm.summary
        
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
