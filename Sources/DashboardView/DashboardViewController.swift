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
    }

    enum Edge: Int {
        case top
        case bottom
    }

    private var state: State = .closed
    private var layoutWidth: CGFloat = 0
    fileprivate var entries = [String]()
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var summaryLabel: UILabel!
    public var edge: Edge = .bottom

    override func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    func update(with vm: DashboardViewModel) {
        summaryLabel?.attributedText = vm.summary

        entries = vm.entries
        relayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        relayout()
    }

    private func relayout() {
        guard let window = view.window else { return }
        layoutWidth = UIScreen.main.bounds.width

        let size = tableView.sizeThatFits(CGSize(width: layoutWidth, height: CGFloat.greatestFiniteMagnitude))

        view.frame = CGRect(x: 0, y: 0, width: layoutWidth, height: min(UIScreen.main.applicationFrame.height - 44, max(CGFloat(129), size.height + 44 + 10)))
        let heightToShow: CGFloat

        switch state {
        case .closed:
            heightToShow = 44
        case .open:
            heightToShow = view.bounds.height
            break
        }

        window.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - heightToShow, width: UIScreen.main.bounds.width, height: view.frame.height)

        view.layoutIfNeeded()
        tableView.reloadData()
    }

    @IBAction private func expandTapped(_ sender: UIButton) {
        switch state {
        case .closed:
            state = .open
        case .open:
            state = .closed
        }

        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .calculationModeCubicPaced] , animations: {
            self.relayout()
        }, completion: nil)
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
