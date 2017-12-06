//
//  RefreshObserverView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

private var contentOffsetKVOContext = 0

open class RefreshObserverView: UIView {
    var action: RefreshAction?

    private var refreshViewHeight: CGFloat {
        return -frame.origin.y
    }

    private var originalContentOffsetY: CGFloat = 0
    
    var pullToRefreshAnimator: PullToRefreshViewDelegate?
    
    open private(set) var state: PullToRefreshViewState = .done {
        didSet {
            guard oldValue != state else {
                return
            }
            #if DEBUG
                print("Refresher: Change to state: \(state)")
            #endif
            stateChanged(from: oldValue, to: state)
        }
    }

    private var contentInsetTop: CGFloat {
        if #available(iOS 11.0, *) {
            return scrollView.adjustedContentInset.top
        } else {
            return scrollView.contentInset.top
        }
    }
    
    var scrollView: UIScrollView {
        return superview as! UIScrollView
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override open func didMoveToSuperview() {
        guard superview is UIScrollView else {
            fatalError("Refreher can only be used in UIScrollView and it's subclasses.")
        }

        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &contentOffsetKVOContext)
        originalContentOffsetY = scrollView.contentOffset.y
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &contentOffsetKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        let viewHeight = refreshViewHeight
        let offset = scrollView.contentOffset.y + contentInsetTop

        if state != .refreshing  {
            if !scrollView.isDragging {
                if offset <= -viewHeight {
                    // Enough pulling, action should be triggered
                    startAnimating()
                } else {
                    state = .cancel
                    // Mark the refresh as done
                    state = .done
                }
            } else {
                if offset < 0 {
                    // Keep pulling
                    let process = -offset / viewHeight
                    progressAnimating(process)
                }
            }
        }
    }
    
    func stateChanged(from oldState: PullToRefreshViewState, to state: PullToRefreshViewState) {
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
            self.scrollView.contentInset.top += self.refreshViewHeight
            
            }) { (finished) -> Void in
                self.action?(self.scrollView)
        }

        pullToRefreshAnimator?.pullToRefreshAnimationDidStart(self)
    }
    
    open func stopAnimating() {
        state = .done
        
        UIView.animate(withDuration: 0.4, animations: {
            self.scrollView.contentOffset.y = self.originalContentOffsetY
            self.scrollView.contentInset.top -= self.refreshViewHeight
        }) { _ in
            self.state = .done
        }

        pullToRefreshAnimator?.pullToRefreshAnimationDidEnd(self)
    }
}
