//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public typealias RefreshAction = (_ scrollView: UIScrollView) -> Void

public enum PullToRefreshViewState {
    case pulling
    case readyToRelease
    case refreshing
    case cancel
    case done
}

public enum PullDirection {
    case down
    case up
}

public protocol PullToRefreshViewDelegate: class {
    func pullToRefreshAnimationDidStart(_ view: RefreshObserverView, direction: PullDirection)
    func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView, direction: PullDirection)
    func pullToRefresh(_ view: RefreshObserverView, progressDidChange progress: CGFloat, direction: PullDirection)
    func pullToRefresh(_ view: RefreshObserverView, stateDidChange state: PullToRefreshViewState, direction: PullDirection)
}

private var pullDownToRefreshViewKey = 0
private var pullUpToRefershViewKey = 1

public extension UIScrollView {
    public private(set) var pullDownRefreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &pullDownToRefreshViewKey) as? RefreshObserverView
        }
        set {
            objc_setAssociatedObject(self, &pullDownToRefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public private(set) var pullUpRefreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &pullUpToRefershViewKey) as? RefreshObserverView
        }
        set {
            objc_setAssociatedObject(self, &pullUpToRefershViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: Pull To Refresh
    
    /// Add a standard pull-to-refresh view to scroll view
    ///
    /// - Parameter action: the action performed when released
    public func addPullToRefresh(_ direction: PullDirection = .down, action: @escaping RefreshAction) {
        let view = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        view.autoresizingMask = [.flexibleWidth, .flexibleRightMargin]
        addPullToRefresh(view, direction: direction, action: action)
    }

    /// Add a custom pull-to-refresh view to scroll view
    ///
    /// - Parameters:
    ///   - refreshView: the custom refresh view
    ///   - action: the action performed when released
    public func addPullToRefresh<T: UIView>(_ view: T, direction: PullDirection = .down, action: @escaping RefreshAction) where T: PullToRefreshViewDelegate {
        if refreshView(with: direction) != nil {
            return
        }
        
        let isPullingDown = (direction == .down)
        let y = isPullingDown ? -view.frame.height : contentSize.height
        let refreshObserver = RefreshObserverView(frame: CGRect(x: 0, y: y, width: bounds.width, height: y))
        refreshObserver.autoresizingMask = [.flexibleWidth, .flexibleRightMargin]
        refreshObserver.direction = direction
        refreshObserver.action = action
        refreshObserver.pullToRefreshAnimator = view
        refreshObserver.refreshView = view
        refreshObserver.addSubview(view)
        
        setRefreshView(refreshObserver, direction: direction)
        addSubview(refreshObserver)
    }

    /// Stop refreshing. In most cases, you should stop the refresh manually.
    public func stopRefresh(_ direction: PullDirection = .down) {
        refreshView(with: direction)?.stopAnimating()
    }
    
    /// Start the refresh manually.
    public func startRefresh(_ direction: PullDirection = .down) {
        refreshView(with: direction)?.startAnimating()
    }
    
    // MARK: Private getter / setter
    
    private func refreshView(with direction: PullDirection = .down) -> RefreshObserverView? {
        switch direction {
        case .down:
            return pullDownRefreshView
        case .up:
            return pullUpRefreshView
        }
    }
    
    private func setRefreshView(_ view: RefreshObserverView, direction: PullDirection = .down) {
        switch direction {
        case .down:
            pullDownRefreshView = view
        case .up:
            pullUpRefreshView = view
        }
    }
    
}
