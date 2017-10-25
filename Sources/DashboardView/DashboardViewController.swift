//
//  DashboardView.swift
//  LifetimeTracker
//
//  Created by Krzysztof Zablocki on 9/25/17.
//

import UIKit

struct DashboardViewModel {
    let summary: NSAttributedString
    let entries: [String]
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

    private var state: State = .closed {
        didSet { self.clampDragOffset() }
    }

    fileprivate var entries = [String]()
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var summaryLabel: UILabel!
    public var edge: Edge = .bottom

    private let closedHeight: CGFloat = 44
    private var originalOffset: CGFloat = 0
    private var dragOffset: CGFloat = 0 {
        didSet { relayout() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
        tableView.scrollsToTop = false

        addPanGestureRecognizer()
        dragOffset = maximumYPosition
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    func update(with vm: DashboardViewModel) {
        summaryLabel?.attributedText = vm.summary

        entries = vm.entries

        tableView.reloadData()
        tableView.layoutIfNeeded()
        relayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        relayout()
    }

    // MARK: - Layout

    private var heightToShow: CGFloat {
        switch state {
        case .closed:
            return closedHeight
        case .open:
            return heightToFitTableView
        }
    }

    private var maximumYPosition: CGFloat {
        return UIScreen.main.bounds.height - heightToShow
    }

    private var heightToFitTableView: CGFloat {
        let size = tableView.contentSize
        return max(CGFloat(129), size.height + closedHeight + 10)
    }

    private var layoutWidth: CGFloat { return UIScreen.main.bounds.width }

    private func relayout() {
        guard let window = view.window else { return }

        view.frame = CGRect(x: 0, y: 0, width: layoutWidth, height: heightToShow)
        window.frame = CGRect(x: 0, y: dragOffset, width: UIScreen.main.bounds.width, height: view.frame.height)

        view.layoutIfNeeded()
    }

    // MARK: - Expand / collapse

    @IBAction private func expandTapped(_ sender: UIButton) {
        state = state.opposite

        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced] , animations: {
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
        default: break
        }
    }

    func clampDragOffset() {
        dragOffset = max(44, min(maximumYPosition, dragOffset))
    }
}

extension DashboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = entries[indexPath.row]
        return cell
    }
}
