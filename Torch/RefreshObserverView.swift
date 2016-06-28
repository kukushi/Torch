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
    
    public private(set) var state: PullToRefreshViewState = .pulling {
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
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
            originalInsetTop = scrollView.contentInset.top +  (isInsetAdjusted ? 64 : 0)
            originalContentOffsetY = scrollView.contentOffset.y - (isInsetAdjusted ? 64 : 0)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if keyPath == "contentOffset" {
            let viewHeight = PullToRefreshViewHeight
            let offset = scrollView.contentOffset.y + originalInsetTop

            if state != .refreshing  {
                if offset > scrollView.contentSize.height - scrollView.frame.height && !triggered {
                    triggered = true
                }
                else if scrollView.isDragging && offset != 0 {
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
    
    func stateChanged(_ state: PullToRefreshViewState) {
        pullToRefreshAnimator?.pullToRefresh(self, stateDidChange: state)
    }
    
    func progressAnimating(_ process: CGFloat) {
        state = process < 1 ? .pulling : .readyToRelease
        pullToRefreshAnimator?.pullToRefresh(self, progressDidChange: process)
    }
    
    func startAnimating() {
        state = .refreshing
        
        UIView.animate(withDuration: 0.4, animations: { [unowned self]() -> Void in
            self.scrollView.contentOffset.y = 0
            self.scrollView.contentInset.top += PullToRefreshViewHeight
            
            }) { (finished) -> Void in
                self.action?(scrollView: self.scrollView)
        }
        
        pullToRefreshAnimator?.pullToRefreshAnimationDidStart(self)
    }
    
    public func stopAnimating() {
        state = .done
        
        UIView.animate(withDuration: 0.4, animations: { [unowned self] in
            self.scrollView.contentOffset.y = self.originalContentOffsetY
            self.scrollView.contentInset.top -= PullToRefreshViewHeight
        }) { [unowned self] _ in
                self.state = .done
        }
        pullToRefreshAnimator?.pullToRefreshAnimationDidEnd(self)
    }
}
