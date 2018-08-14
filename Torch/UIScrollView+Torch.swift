//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

private var pullDownToRefreshViewKey = 0
private var pullUpToRefershViewKey = 1

public extension UIScrollView {
    private var pullDownObserver: PullObserver? {
        get {
            return objc_getAssociatedObject(self, &pullDownToRefreshViewKey) as? PullObserver
        }
        set {
            objc_setAssociatedObject(self, &pullDownToRefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private var pullUpObserver: PullObserver? {
        get {
            return objc_getAssociatedObject(self, &pullUpToRefershViewKey) as? PullObserver
        }
        set {
            objc_setAssociatedObject(self, &pullUpToRefershViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: Pull To Refresh

    /// Add a standard pull-to-refresh view to scroll view
    ///
    /// - Parameter action: the action performed when released
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
        if pullObserver(with: option.direction) != nil {
            return
        }

        let refreshObserver = PullObserver(refreshView: view, option: option, action: action)
        setPullObserver(refreshObserver, direction: direction)

        let containerView = PullContainerView()
        containerView.observer = refreshObserver
        refreshObserver.containerView = containerView

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = direction == .down ? containerView.bottomAnchor.constraint(equalTo: topAnchor) :
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: contentSize.height)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor),
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
    public func stopRefresh(_ direction: PullDirection = .down, animated: Bool = true, scrollToOriginalPosition: Bool = true) {
        pullObserver(with: direction)?.stopAnimating(animated: animated, scrollToOriginalPosition: scrollToOriginalPosition)
    }

    /// Start the refresh manually.
    public func startRefresh(_ direction: PullDirection = .down, animated: Bool = true) {
        pullObserver(with: direction)?.startAnimating(animated: animated)
    }

    // MARK: Observer getter / setter

    private func pullObserver(with direction: PullDirection = .down) -> PullObserver? {
        switch direction {
        case .down:
            return pullDownObserver
        case .up:
            return pullUpObserver
        }
    }

    private func setPullObserver(_ observer: PullObserver, direction: PullDirection = .down) {
        switch direction {
        case .down:
            pullDownObserver = observer
        case .up:
            pullUpObserver = observer
        }
    }

}
