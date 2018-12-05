//
//  TorchControl.swift
//  Torch
//
//  Created by kukushi on 2018/12/5.
//  Copyright © 2018 Xing He. All rights reserved.
//

import UIKit

public class TorchControl {
    private weak var baseView: UIScrollView?
    private var pullDownObserver: ScrollObserver?
    private var pullUpObserver: ScrollObserver?
    public var isEnabled: Bool = true {
        didSet {
            pullDownObserver?.isEnabled = isEnabled
            pullUpObserver?.isEnabled = isEnabled
        }
    }

    init(baseView: UIScrollView) {
        self.baseView = baseView
    }

    public func state(of direction: PullDirection) -> PullState {
        return pullObserver(with: direction)?.state ?? .done
    }

    // MARK: Pull To Refresh

    /// Add a standard pull-to-refresh view to scroll view
    ///
    /// - Parameter action: the action performed when released
    public func addPullToRefresh(_ option: PullOption, action: @escaping RefreshAction) {
        let view = PlainRefreshView()
        addPullToRefresh(view, option: option, action: action)
    }

    /// Add a custom pull-to-refresh view to scroll view
    ///
    /// - Parameters:
    ///   - refreshView: the custom refresh view
    ///   - action: the action performed when released
    public func addPullToRefresh(_ view: RefreshView, option: PullOption, action: @escaping RefreshAction) {
        let direction = option.direction
        guard pullObserver(with: option.direction) == nil else {
            assertionFailure("Redundant pull to refresh added to a scroll view")
            return
        }

        guard let baseView = baseView else {
            assertionFailure("Scroll view already deallocated before adding refresh control")
            return
        }

        let refreshObserver = ScrollObserver(refreshView: view, option: option, action: action)
        setPullObserver(refreshObserver, direction: direction)

        let containerView = PullContainerView()
        containerView.observer = refreshObserver

        refreshObserver.containerView = containerView

        baseView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = direction == .down ? containerView.bottomAnchor.constraint(equalTo: baseView.topAnchor) :
            containerView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: baseView.contentSize.height)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: baseView.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: option.areaHeight),
            topConstraint
            ])

        refreshObserver.topConstraint = topConstraint

        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            view.widthAnchor.constraint(equalToConstant: view.preferredSize().width),
            view.widthAnchor.constraint(equalToConstant: view.preferredSize().height)
        ])
    }

    /// Stop refreshing. In most cases, you should stop the refresh manually.
    public func stopRefresh(_ direction: PullDirection, animated: Bool = true, scrollToOriginalPosition: Bool = true) {
        pullObserver(with: direction)?.stopAnimating(animated: animated, scrollToOriginalPosition: scrollToOriginalPosition)
    }

    /// Start the refresh manually.
    public func startRefresh(_ direction: PullDirection = .down, animated: Bool = true) {
        pullObserver(with: direction)?.startAnimating(animated: animated)
    }

    // MARK: Observer getter / setter

    private func pullObserver(with direction: PullDirection = .down) -> ScrollObserver? {
        switch direction {
        case .down:
            return pullDownObserver
        case .up:
            return pullUpObserver
        }
    }

    private func setPullObserver(_ observer: ScrollObserver, direction: PullDirection = .down) {
        switch direction {
        case .down:
            pullDownObserver = observer
        case .up:
            pullUpObserver = observer
        }
    }

}
