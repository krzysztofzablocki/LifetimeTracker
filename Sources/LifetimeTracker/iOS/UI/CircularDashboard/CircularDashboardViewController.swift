//
//  CircularDashboardViewController.swift
//  LifetimeTracker-iOS
//
//  Created by Hans Seiffert on 17.03.18.
//  Copyright © 2018 LifetimeTracker. All rights reserved.
//

import UIKit

enum PopoverVisibility {
    case open
    case closed
}

protocol LifetimeTrackerViewable {

    static func makeFromNib() -> UIViewController & LifetimeTrackerViewable

    func update(with vm: BarDashboardViewModel)
}

class CircularDashboardViewController: UIViewController, LifetimeTrackerViewable {

    @IBOutlet weak var roundView: UIView!

    @IBOutlet weak var leaksCountLabel: UILabel?
    @IBOutlet weak var leaksTitleLabel: UILabel?

    weak var lifetimeTrackerListViewController: LifetimeTrackerListViewController?

    fileprivate var formerStatusBarStyle = UIApplication.shared.statusBarStyle

    private var didInitializeRoundView = false

    private var hideOption: HideOption = .none {
        didSet {
            if hideOption != .none {
                view.isHidden = true
            }
        }
    }

    private var dashboardViewModel = BarDashboardViewModel() {
        didSet {
            lifetimeTrackerListViewController?.update(dashboardViewModel: dashboardViewModel)
        }
    }

    class func makeFromNib() -> UIViewController & LifetimeTrackerViewable {
        let storyboard = UIStoryboard(name: Constants.Storyboard.circularDashboard.name, bundle: .resolvedBundle)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! CircularDashboardViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false

        addPanGestureRecognizer()
        addTapGestureRecognizer()
        addLongPressGestureRecognizer()

        relayout()
    }

    func addPanGestureRecognizer() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(toolbarPanned))
        view.addGestureRecognizer(panGestureRecognizer)
    }

    func addTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showPopover))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    func addLongPressGestureRecognizer() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showSettings))
        view.addGestureRecognizer(longPressGestureRecognizer)
    }

    var dragOffset = CGSize.zero {
        didSet { relayout() }
    }

    var originalOffset = CGSize.zero

    @objc func toolbarPanned(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            originalOffset = dragOffset
        case .changed:
            let translation = gestureRecognizer.translation(in: self.view)
            dragOffset.height = originalOffset.height + translation.y
            dragOffset.width = originalOffset.width + translation.x
        default:
            UIView.animate(withDuration: Constants.Layout.animationDuration * 2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.clampDragOffset()
            }, completion: nil)
        }
    }

    @objc func showSettings(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            guard let originalFrame = view.window?.frame else {
                return
            }
            let roundViewFrame = roundView.frame
            roundView.translatesAutoresizingMaskIntoConstraints = true
            roundView.frame = CGRect(x: originalFrame.origin.x + roundViewFrame.origin.x, y: originalFrame.origin.y + roundViewFrame.origin.y, width: roundViewFrame.width, height: roundViewFrame.height)
            view.window?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            SettingsManager.showSettingsActionSheet(on: self, completionHandler: { [weak self] (selecetedOption: HideOption) in
                self?.changeHideOption(for: selecetedOption)
                self?.roundView.translatesAutoresizingMaskIntoConstraints = false
                self?.relayout()
            })
        }
    }

    func clampDragOffset() {
        let maxHiddenWidth = view.frame.size.width * 0.4
        if dragOffset.width < -maxHiddenWidth {
            dragOffset.width = -maxHiddenWidth
        } else if dragOffset.width > UIScreen.main.bounds.width - view.frame.size.width + maxHiddenWidth {
            dragOffset.width = UIScreen.main.bounds.width - view.frame.size.width + maxHiddenWidth
        }

        let maxHiddenHeight = view.frame.size.height * 0.4
        if dragOffset.height < -maxHiddenHeight {
            dragOffset.height = -maxHiddenHeight
        } else if dragOffset.height > UIScreen.main.bounds.height - view.frame.size.height + maxHiddenHeight {
            dragOffset.height = UIScreen.main.bounds.height - view.frame.size.height + maxHiddenHeight
        }
    }

    func update(with vm: BarDashboardViewModel) {
        leaksCountLabel?.text = "\(vm.leaksCount)"
        leaksCountLabel?.textColor = vm.leaksCount == 0
            ? vm.textColorForNoIssues
            : vm.textColorForLeakDetected
        leaksTitleLabel?.text = vm.leaksCount == 1 ? "word.leak".lt_localized : "word.leaks".lt_localized

        if hideOption.shouldUIBeShown(oldModel: dashboardViewModel, newModel: vm) {
            view.isHidden = false
            hideOption = .none
        }

        dashboardViewModel = vm

        relayout()
    }

    private func relayout() {
        guard let window = view.window else {
            return
        }

        let width = CGFloat(100)

        if !didInitializeRoundView {
            didInitializeRoundView = true
            dragOffset = CGSize(width: UIScreen.main.bounds.size.width - width * 0.7, height: 100)
            clampDragOffset()

            roundView.layer.cornerRadius = self.roundView.frame.height / 2

            roundView.clipsToBounds = false
            roundView.layer.shadowColor = UIColor.black.cgColor
            roundView.layer.shadowOpacity = 1
            roundView.layer.shadowOffset = CGSize.zero
            roundView.layer.shadowRadius = 4
            roundView.layer.shadowPath = UIBezierPath(roundedRect: roundView.bounds, cornerRadius: self.roundView.frame.height / 2).cgPath
        }

        // Prevent black areas during device orientation
        window.clipsToBounds = true
        window.translatesAutoresizingMaskIntoConstraints = true
        window.frame = CGRect(x: dragOffset.width, y: dragOffset.height, width: width, height: width)
        view.layoutIfNeeded()
    }

    private lazy var popoverWindow: UIWindow = {
        var frame: CGRect = UIScreen.main.bounds
        let popoverWindow = UIWindow(frame: .zero)

        if #available(iOS 13.0, *), let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            frame = windowScene.coordinateSpace.bounds
            popoverWindow.windowScene = windowScene
        }

        popoverWindow.windowLevel = UIWindow.Level.normal
        popoverWindow.frame =  frame

        let navigationController = UIStoryboard(name: Constants.Storyboard.circularDashboard.name, bundle: .resolvedBundle).instantiateInitialViewController()
        popoverWindow.rootViewController = navigationController
        popoverWindow.rootViewController?.view.backgroundColor = UIColor.yellow

        self.lifetimeTrackerListViewController = navigationController?.children.first as? LifetimeTrackerListViewController
        self.lifetimeTrackerListViewController?.delegate = self
        self.lifetimeTrackerListViewController?.update(dashboardViewModel: self.dashboardViewModel)

        return popoverWindow
    }()

    @objc func showPopover() {
        formerStatusBarStyle = UIApplication.shared.statusBarStyle
        UIApplication.shared.statusBarStyle = .default
        updatePopoverVisibility(to: .open)
    }

    func updatePopoverVisibility(to state: PopoverVisibility) {
        let openedFrame = UIScreen.main.bounds
        var closedFrame = openedFrame
        closedFrame.origin.y = closedFrame.size.height

        popoverWindow.frame = state == .open ? closedFrame : openedFrame

        popoverWindow.isHidden = false
        view.window?.alpha = state == .closed ? 0 : 1

        UIView.animateKeyframes(withDuration: Constants.Layout.animationDuration, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced] , animations: {
            self.popoverWindow.frame = state == .open ? openedFrame : closedFrame
            self.view.window?.alpha = state == .open ? 0 : 1
        }, completion: { (finished: Bool) in
            self.popoverWindow.isHidden = state == .closed
        })
    }
}

extension CircularDashboardViewController: PopoverViewControllerDelegate {

    func dismissPopoverViewController() {
        updatePopoverVisibility(to: .closed)
        UIApplication.shared.statusBarStyle = formerStatusBarStyle
    }

    func changeHideOption(for hideOption: HideOption) {
        self.hideOption = hideOption
        if !popoverWindow.isHidden {
            dismissPopoverViewController()
        }
    }
}

extension CircularDashboardViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        popoverPresentationController.permittedArrowDirections = .any
        popoverPresentationController.sourceView = self.roundView
    }
}
