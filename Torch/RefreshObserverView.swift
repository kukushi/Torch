//
//  RefreshObserverView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

public class RefreshObserverView: UIView {
    var action: RefreshAction?
    
    public var isInsetAdjusted = false
    
    private var originalInsetTop: CGFloat = 0
    private var originalContentOffsetY: CGFloat = 0

    private var triggered = false
    
    var pullToRefreshAnimator: PullToRefreshViewDelegate?
    
    public private(set) var state: PullToRefreshViewState = .Pulling {
        didSet {
            stateChanged(state)
        }
    }
    
    var scrollView: UIScrollView! {
        return superview as? UIScrollView
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override public func didMoveToSuperview() {
        if scrollView != nil {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
            originalInsetTop = scrollView.contentInset.top +  (isInsetAdjusted ? 64 : 0)
            originalContentOffsetY = scrollView.contentOffset.y - (isInsetAdjusted ? 64 : 0)
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            let viewHeight = PullToRefreshViewHeight
            let offset = scrollView.contentOffset.y + originalInsetTop

            if state != .Refreshing  {
                if offset > scrollView.contentSize.height - scrollView.frame.height && !triggered {
                    triggered = true
                }
                else if scrollView.dragging && offset != 0 {
                    let process = -offset / viewHeight
                    progressAnimating(process)
                }
                else if viewHeight != 0 && offset < -viewHeight {
                    startAnimating()
                }
                else if offset <= scrollView.contentSize.height - scrollView.frame.height && triggered {
                    triggered = false
                }
            }
        }
    }
    
    func stateChanged(state: PullToRefreshViewState) {
        pullToRefreshAnimator?.pullToRefresh(self, stateDidChange: state)
    }
    
    func progressAnimating(process: CGFloat) {
        state = process < 1 ? .Pulling : .ReadyToRelease
        pullToRefreshAnimator?.pullToRefresh(self, progressDidChange: process)
    }
    
    func startAnimating() {
        state = .Refreshing
        
        UIView.animateWithDuration(0.4, animations: { [unowned self]() -> Void in
            self.scrollView.contentOffset.y = 0
            self.scrollView.contentInset.top += PullToRefreshViewHeight
            
            }) { (finished) -> Void in
                self.action?(scrollView: self.scrollView)
        }
        
        pullToRefreshAnimator?.pullToRefreshAnimationDidStart(self)
    }
    
    public func stopAnimating() {
        state = .Pulling
        
        UIView.animateWithDuration(0.4, animations: { [unowned self] () -> Void in
            self.scrollView.contentOffset.y = self.originalContentOffsetY
            self.scrollView.contentInset.top -= PullToRefreshViewHeight
        })
        
        pullToRefreshAnimator?.pullToRefreshAnimationDidEnd(self)
    }
}
