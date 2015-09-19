//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public typealias RefreshAction = () -> Void

private var RefreshViewKey = "RefreshViewKey"
private var LoadMoreViewKey = "LoadMoreViewKey"

public extension UIScrollView {
    public private(set) var refreshView: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &RefreshViewKey) as? RefreshView
        }
        
        set {
            self.refreshView?.removeFromSuperview()
            
            objc_setAssociatedObject(self, &RefreshViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let view = newValue {
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                let constraints = [
                    NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
                ]
                addConstraints(constraints)
            }
        }
    }
    
    public private(set) var loadMoreView: LoadMoreView? {
        get {
            return objc_getAssociatedObject(self, &LoadMoreViewKey) as? LoadMoreView
        }
        
        set {
            self.refreshView?.removeFromSuperview()
            
            objc_setAssociatedObject(self, &LoadMoreViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let view = newValue {
                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                let constraints = [
                    NSLayoutConstraint(item: view, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
                ]
                addConstraints(constraints)
            }
        }
    }
    
    public func addPullDownRefresher(refreshView: RefreshView, action: RefreshAction) {
        self.refreshView = refreshView
        addSubview(refreshView)
        refreshView.action = action
    }
    
    public func addLoadMoreRefresher(loadMoreView: LoadMoreView, action: RefreshAction) {
        self.loadMoreView = loadMoreView;
        addSubview(loadMoreView)
        loadMoreView.action = action
    }
    
    public func stopRefresh() {
        refreshView?.stopAnimating()
    }
    
    public func startRefresh() {
        refreshView?.startAnimating()
    }
}