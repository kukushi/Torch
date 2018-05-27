//
//  RefreshObserverView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

private var TrochContentOffsetKVOContext = 0
private var TorchContentSizeKVOContext = 1
private let TorchContentOffsetKey = "contentOffset"
private let TorchContentSizetKey = "contentSize"

open class RefreshObserverView: UIView {
    var action: RefreshAction?
    var direction = PullDirection.down
    weak var refreshView: UIView?

    private var refreshViewHeight: CGFloat {
        return refreshView?.frame.height ?? 0
    }
    
    private var isPullingDown: Bool {
        return direction == .down
    }

    private var originalContentOffsetY: CGFloat = 0
    
    weak var pullToRefreshAnimator: PullToRefreshViewDelegate?
    
    open private(set) var state: PullToRefreshViewState = .done {
        didSet {
            guard oldValue != state else {
                return
            }
            stateChanged(from: oldValue, to: state)
            
            #if DEBUG
            print("[Refresher]: Change to state: \(state)")
            #endif
        }
    }
    
    private var refersherContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return scrollView.adjustedContentInset
        } else {
            return scrollView.contentInset
        }
    }
    
    var scrollView: UIScrollView {
        return superview as! UIScrollView
    }
    
    deinit {
        #if DEBUG
        print("[Refresher]: deinit")
        #endif
        superview?.removeObserver(self, forKeyPath: TorchContentOffsetKey)
        superview?.removeObserver(self, forKeyPath: TorchContentSizetKey)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            scrollView.removeObserver(self, forKeyPath: TorchContentOffsetKey)
            if !isPullingDown {
                scrollView.removeObserver(self, forKeyPath: TorchContentSizetKey)
            }
        }
    }
    
    override open func didMoveToSuperview() {
        if superview == nil {
            return
        }
        
        guard superview is UIScrollView else {
            fatalError("Refreher can only be used in UIScrollView and it's subclasses.")
        }

        scrollView.addObserver(self, forKeyPath: TorchContentOffsetKey, options: .new, context: &TrochContentOffsetKVOContext)
        originalContentOffsetY = scrollView.contentOffset.y
        
        if !isPullingDown {
            scrollView.addObserver(self, forKeyPath: TorchContentSizetKey, options: .new, context: &TorchContentSizeKVOContext)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch context {
        case &TrochContentOffsetKVOContext:
            observingContentOffsetChanges()
        case &TorchContentSizeKVOContext:
            observingContentSizeChanges()
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: KVO
    
    func observingContentOffsetChanges() {
        let viewHeight = refreshViewHeight
        
        guard state != .refreshing else { return }
        
        switch direction {
        case .down:
            let offset = scrollView.contentOffset.y + refersherContentInset.top
            if !scrollView.isDragging {
                if offset <= -viewHeight {
                    // Enough pulling, action should be triggered
                    startAnimating()
                } else if offset < 0 && state == .pulling {
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
        case .up:
            let offset = scrollView.contentOffset.y - refersherContentInset.bottom
            let contentHeight = scrollView.contentSize.height
            let containerHeight = scrollView.frame.height
            if contentHeight < containerHeight {
                return
            }
            let bottfomOffset = containerHeight + offset - contentHeight
            if scrollView.isDragging {
                if bottfomOffset > 0 && bottfomOffset < viewHeight {
                    let process = bottfomOffset / viewHeight
                    progressAnimating(process)
                }
            } else {
                if bottfomOffset >= viewHeight {
                    startAnimating()
                } else if bottfomOffset > 0 && state == .pulling {
                    state = .cancel
                    // Mark the refresh as done
                    state = .done
                }
            }
        }
    }
    
    func observingContentSizeChanges() {
        if let origin = refreshView?.frame.origin, origin.y != scrollView.contentSize.height {
            refreshView?.frame.origin.y = scrollView.contentSize.height
        }
    }
    
    // MARK:
    
    func stateChanged(from oldState: PullToRefreshViewState, to state: PullToRefreshViewState) {
        pullToRefreshAnimator?.pullToRefresh(self, stateDidChange: state)
    }
    
    func progressAnimating(_ process: CGFloat) {
        state = process < 1 ? .pulling : .readyToRelease
        pullToRefreshAnimator?.pullToRefresh(self, progressDidChange: process)
    }
    
    func startAnimating() {
        state = .refreshing
        
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            if self.isPullingDown {
                self.scrollView.contentInset.top += self.refreshViewHeight
                self.scrollView.contentOffset.y = self.originalContentOffsetY - self.refreshViewHeight
            } else {
                self.scrollView.contentInset.bottom += self.refreshViewHeight
                self.scrollView.contentOffset.y += self.refreshViewHeight
            }
        }) { (finished) -> Void in
            self.pullToRefreshAnimator?.pullToRefreshAnimationDidStart(self)
            self.action?(self.scrollView)
        }
    }
    
    open func stopAnimating() {
        state = .done
        
        self.pullToRefreshAnimator?.pullToRefreshAnimationDidEnd(self)
        
        UIView.animate(withDuration: 0.4, animations: {
            if self.isPullingDown {
                self.scrollView.contentOffset.y = self.originalContentOffsetY
                self.scrollView.contentInset.top -= self.refreshViewHeight
            } else {
                let contentHeight = self.scrollView.contentSize.height
                let containerHeight = self.scrollView.frame.height
                self.scrollView.contentInset.bottom -= self.refreshViewHeight
                self.scrollView.contentOffset.y = contentHeight - containerHeight + self.refersherContentInset.bottom
            }
        }) { _ in
            self.state = .done
        }
    }
}
