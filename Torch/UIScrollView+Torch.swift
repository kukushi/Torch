//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public typealias RefreshAction = (scrollView: UIScrollView) -> Void

private var RefreshViewKey = "com.kukushi.RefreshViewKey"
private var PullUpRefreshViewKey = "com.kukushi.PullUpRefreshViewKey"

let PullToRefreshViewHeight = CGFloat(44)

public enum PullToRefreshViewState {
    case Refreshing
    case Pulling
    case ReadyToRelease
}

public protocol PullToRefreshViewDelegate {
    func pullToRefreshAnimationDidStart(view: RefreshObserverView)
    func pullToRefreshAnimationDidEnd(view: RefreshObserverView)
    func pullToRefresh(view: RefreshObserverView, progressDidChange progress: CGFloat)
    func pullToRefresh(view: RefreshObserverView, stateDidChange state: PullToRefreshViewState)
}

public extension UIScrollView {

    // MARK:

    public private(set) var refreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &RefreshViewKey) as? RefreshObserverView
        }
        
        set {
            objc_setAssociatedObject(self, &RefreshViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public private(set) var pullUpRefreshView: RefreshObserverView? {
        get {
            return objc_getAssociatedObject(self, &PullUpRefreshViewKey) as? RefreshObserverView
        }
        
        set {
            self.pullUpRefreshView?.removeFromSuperview()
            objc_setAssociatedObject(self, &PullUpRefreshViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK:
    
    
    public func addPullToRefresh(action: RefreshAction) {
        let refreshOberver = RefreshObserverView(frame: CGRectMake(0, -PullToRefreshViewHeight, 0, 0))
        refreshOberver.action = action
        
        let width = UIScreen.mainScreen().bounds.width
        let refreshView = PlainRefreshView(frame: CGRectMake(0, 0, width, PullToRefreshViewHeight))
        refreshOberver.pullToRefreshAnimator = refreshView
        refreshOberver.addSubview(refreshView)
        
        self.refreshView = refreshOberver
        addSubview(refreshOberver)
    }
    
    public func addPullToRefresh<T: UIView where T: PullToRefreshViewDelegate>(refreshView: T, action: RefreshAction) {
        let refreshOberver = RefreshObserverView(frame: CGRectMake(0, -PullToRefreshViewHeight, 0, 0))
        refreshOberver.action = action
        
        refreshOberver.pullToRefreshAnimator = refreshView
        refreshOberver.addSubview(refreshView)
        
        self.refreshView = refreshOberver
        addSubview(refreshOberver)
    }

//    public func addPullDownRefresher<T: UIView where T: RefreshViewDelegate>(refreshView: T, action: RefreshAction) {
//        self.refreshView = refreshView
//        addSubview(refreshView)
//        refreshView.action = action
//    }
//    
//    public func addPullUpRefresher(refreshView: RefreshView, action: RefreshAction) {
//        self.pullUpRefreshView = refreshView
//        addSubview(refreshView)
//        refreshView.pullUpAction = action
//    }
    
    // MARK:
    
    public func stopRefresh() {
        refreshView?.stopAnimating()
    }
    
    public func startRefresh() {
        refreshView?.startAnimating()
    }
}