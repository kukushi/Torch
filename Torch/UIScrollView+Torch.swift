//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public typealias RefreshAction = (_ scrollView: UIScrollView) -> Void

private var RefreshViewKey = "com.kukushi.RefreshViewKey"
private var PullUpRefreshViewKey = "com.kukushi.PullUpRefreshViewKey"

let PullToRefreshViewHeight = CGFloat(44)

public enum PullToRefreshViewState {
    case refreshing
    case pulling
    case readyToRelease
    case done
}

public protocol PullToRefreshViewDelegate {
    func pullToRefreshAnimationDidStart(_ view: RefreshObserverView)
    func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView)
    func pullToRefresh(_ view: RefreshObserverView, progressDidChange progress: CGFloat)
    func pullToRefresh(_ view: RefreshObserverView, stateDidChange state: PullToRefreshViewState)
}

public extension UIScrollView {
    public fileprivate(set) var refreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &RefreshViewKey) as? RefreshObserverView
        }
        
        set {
            objc_setAssociatedObject(self, &RefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public fileprivate(set) var pullUpRefreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &PullUpRefreshViewKey) as? RefreshObserverView
        }
        
        set {
            self.pullUpRefreshView?.removeFromSuperview()
            objc_setAssociatedObject(self, &PullUpRefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /**
     Add a standard pull-to-refresh view to scroll view
     
     - parameter action: the action performed when refreshing
     */
    public func addPullToRefresh(_ action: @escaping RefreshAction) {
        let refreshOberver = RefreshObserverView(frame: CGRect(x: 0, y: -PullToRefreshViewHeight, width: 0, height: 0))
        refreshOberver.action = action
        
        let width = UIScreen.main.bounds.width
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: width, height: PullToRefreshViewHeight))
        refreshOberver.pullToRefreshAnimator = refreshView
        refreshOberver.addSubview(refreshView)
        
        self.refreshView = refreshOberver
        addSubview(refreshOberver)
    }
    
    /**
     Add a custom pull-to-refresh view to scroll view
     
     - parameter refreshView: the custom refresh view
     - parameter action:      the action performed when reshing
     */
    public func addPullToRefresh<T: UIView>(_ refreshView: T, action: @escaping RefreshAction) where T: PullToRefreshViewDelegate {
        let refreshOberver = RefreshObserverView(frame: CGRect(x: 0, y: -PullToRefreshViewHeight, width: 0, height: 0))
        refreshOberver.action = action
        
        refreshOberver.pullToRefreshAnimator = refreshView
        refreshOberver.addSubview(refreshView)
        
        self.refreshView = refreshOberver
        addSubview(refreshOberver)
    }
    
    /**
     Stop refreshing. In most cases, you should stop the refresh manually.
     */
    public func stopRefresh() {
        refreshView?.stopAnimating()
    }
    
    /**
     Start the refresh manually.
     */
    public func startRefresh() {
        refreshView?.startAnimating()
    }
}
