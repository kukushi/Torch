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
    func pullToRefreshAnimationDidStart(_ view: RefreshObserverView)
    func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView)
    func pullToRefresh(_ view: RefreshObserverView, progressDidChange progress: CGFloat)
    func pullToRefresh(_ view: RefreshObserverView, stateDidChange state: PullToRefreshViewState)
}

private var pullDownToRefreshViewKey = 0
private var pullUpToRefershViewKey = 1

public extension UIScrollView {
    public private(set) var pullDownRefreshView: RefreshObserverView? {
        get { return objc_getAssociatedObject(self, &pullDownToRefreshViewKey) as? RefreshObserverView }
        set { objc_setAssociatedObject(self, &pullDownToRefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public private(set) var pullUpRefreshView: RefreshObserverView? {
        get { return objc_getAssociatedObject(self, &pullUpToRefershViewKey) as? RefreshObserverView }
        set { objc_setAssociatedObject(self, &pullUpToRefershViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: Pull To Refresh
    
    /// Add a standard pull-to-refresh view to scroll view
    ///
    /// - Parameter action: the action performed when released
    public func addPullToRefresh(_ direction: PullDirection = .down, action: @escaping RefreshAction) {
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: 44))
        
        let isPullingDown = direction == .down
        let y = isPullingDown ? -refreshView.frame.height : contentSize.height
        let refreshObserver = RefreshObserverView(frame: CGRect(x: 0, y: y, width: 0, height: 0))
        refreshObserver.direction = direction
        refreshObserver.action = action
        refreshObserver.pullToRefreshAnimator = refreshView
        refreshObserver.refreshView = refreshView
        refreshObserver.addSubview(refreshView)
        
        setRefreshView(refreshObserver, direction: direction)
        addSubview(refreshObserver)
    }

    /// Add a custom pull-to-refresh view to scroll view
    ///
    /// - Parameters:
    ///   - refreshView: the custom refresh view
    ///   - action: the action performed when released
    public func addPullToRefresh<T: UIView>(_ refreshView: T, direction: PullDirection = .down, action: @escaping RefreshAction) where T: PullToRefreshViewDelegate {
        let isPullingDown = direction == .down
        let y = isPullingDown ? -refreshView.frame.height : contentSize.height
        let refreshObserver = RefreshObserverView(frame: CGRect(x: 0, y: y, width: 0, height: 0))
        refreshObserver.direction = direction
        refreshObserver.action = action
        refreshObserver.pullToRefreshAnimator = refreshView
        refreshObserver.refreshView = refreshView
        refreshObserver.addSubview(refreshView)
        
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
        return direction == .down ? pullDownRefreshView : pullUpRefreshView
    }
    
    private func setRefreshView(_ view: RefreshObserverView, direction: PullDirection = .down) {
        if direction == .down {
            pullDownRefreshView = view
        } else {
            pullUpRefreshView = view
        }
    }
    
}
