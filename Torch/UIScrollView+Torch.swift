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
    case done
}

public protocol PullToRefreshViewDelegate {
    func pullToRefreshAnimationDidStart(_ view: RefreshObserverView)
    func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView)
    func pullToRefresh(_ view: RefreshObserverView, progressDidChange progress: CGFloat)
    func pullToRefresh(_ view: RefreshObserverView, stateDidChange state: PullToRefreshViewState)
}

private var refreshViewKey = 0

public extension UIScrollView {
    public private(set) var refreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &refreshViewKey) as? RefreshObserverView
        }
        set {
            objc_setAssociatedObject(self, &refreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Add a standard pull-to-refresh view to scroll view
    ///
    /// - Parameter action: the action performed when released
    public func addPullToRefresh(_ action: @escaping RefreshAction) {
        let width = UIScreen.main.bounds.width
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: width, height: 44))

        let refreshObserver = RefreshObserverView(frame: CGRect(x: 0, y: -refreshView.frame.height, width: 0, height: 0))
        refreshObserver.action = action
        refreshObserver.pullToRefreshAnimator = refreshView
        refreshObserver.addSubview(refreshView)
        
        self.refreshView = refreshObserver
        addSubview(refreshObserver)
    }

    /// Add a custom pull-to-refresh view to scroll view
    ///
    /// - Parameters:
    ///   - refreshView: the custom refresh view
    ///   - action: the action performed when released
    public func addPullToRefresh<T: UIView>(_ refreshView: T, action: @escaping RefreshAction) where T: PullToRefreshViewDelegate {
        let viewHeight = refreshView.frame.height
        let refreshObserver = RefreshObserverView(frame: CGRect(x: 0, y: -viewHeight, width: 0, height: 0))
        refreshObserver.action = action
        
        refreshObserver.pullToRefreshAnimator = refreshView
        refreshObserver.addSubview(refreshView)
        
        self.refreshView = refreshObserver
        addSubview(refreshObserver)
    }

    /// Stop refreshing. In most cases, you should stop the refresh manually.
    public func stopRefresh() {
        refreshView?.stopAnimating()
    }
    
    /// Start the refresh manually.
    public func startRefresh() {
        refreshView?.startAnimating()
    }
}
