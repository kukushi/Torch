//
//  RefreshObserverView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

private var TorchContentOffsetKVOContext = 0
private var TorchContentSizeKVOContext = 1
private let TorchContentOffsetKey = "contentOffset"
private let TorchContentSizetKey = "contentSize"

open class PullObserver: NSObject {
    let option: PullOption
    weak var refreshView: RefreshView!
    let action: RefreshAction
    
    weak var containerView: UIView!
    
    private lazy var feedbackGenerator = RefreshFeedbackGenerator()
    
    var topConstraint: NSLayoutConstraint?
    
    private var leastRefreshingHeight: CGFloat = 0
    
    private var direction: PullDirection {
        return option.direction
    }
    
    private var pullingHeight: CGFloat {
        return option.areaHeight + option.topPadding
    }
    
    private var isPullingDown: Bool {
        return direction == .down
    }

    private var originalContentOffsetY: CGFloat = 0
    
    open private(set) var state: PullState = .done {
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
        return containerView.superview as! UIScrollView
    }
    
    init(refreshView: RefreshView, option: PullOption, action: @escaping RefreshAction) {
        self.refreshView = refreshView
        self.option = option
        self.action = action
    }
    
    deinit {
        if containerView != nil {
            containerView.superview?.removeObserver(self, forKeyPath: TorchContentOffsetKey)
            containerView.superview?.removeObserver(self, forKeyPath: TorchContentSizetKey)
        }
    }
    
    func stopObserving() {
        scrollView.removeObserver(self, forKeyPath: TorchContentOffsetKey)
        if !isPullingDown {
            scrollView.removeObserver(self, forKeyPath: TorchContentSizetKey)
        }
    }
    
    func startObserving() {
        if containerView.superview == nil {
            return
        }
        
        guard containerView.superview is UIScrollView else {
            fatalError("Refreher can only be used in UIScrollView and it's subclasses.")
        }

        scrollView.addObserver(self, forKeyPath: TorchContentOffsetKey, options: .new, context: &TorchContentOffsetKVOContext)
        originalContentOffsetY = scrollView.contentOffset.y
        
        if !isPullingDown {
            scrollView.addObserver(self, forKeyPath: TorchContentSizetKey, options: .new, context: &TorchContentSizeKVOContext)
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if context == &TorchContentOffsetKVOContext {
            observingContentOffsetChanges()
        } else if context == &TorchContentSizeKVOContext {
            observingContentSizeChanges()
        }
    }
    
    // MARK: KVO
    
    func observingContentOffsetChanges() {
        let viewHeight = pullingHeight
        
        guard state != .refreshing else {
            return
        }
        
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
                    
                    if option.enableTapticFeedback {
                        feedbackGenerator.reset()
                    }
                }
            } else {
                if offset < 0 {
                    // Still pulling
                    let process = -offset / viewHeight
                    
                    if option.enableTapticFeedback {
                        if state == .done {
                            feedbackGenerator.prepare()
                        }
                        if state == .pulling && process >= 1 {
                            feedbackGenerator.generate()
                        }
                    }
                    
                    state = process < 1 ? .pulling : .readyToRelease
                    progressAnimating(process)
                }
            }
        case .up:
            let contentHeight = scrollView.contentSize.height
            let containerHeight = scrollView.frame.height
            if contentHeight < containerHeight {
                return
            }
            
            let offset = scrollView.contentOffset.y - refersherContentInset.bottom
            let bottfomOffset = containerHeight + offset - contentHeight
            
            if option.startBeforeReachingBottom && state != .refreshing && leastRefreshingHeight != scrollView.contentSize.height {
                if bottfomOffset > -option.startBeforeReachingBottomOffset {
                    leastRefreshingHeight = scrollView.contentSize.height
                    startAnimating()
                }
                return
            }
            
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
        if !isPullingDown {
            topConstraint?.constant = scrollView.contentSize.height
            scrollView.layoutIfNeeded()
        }
    }
    
    // MARK:
    
    func stateChanged(from oldState: PullState, to state: PullState) {
        refreshView.pullToRefresh(refreshView, stateDidChange: state, direction: direction)
    }
    
    func progressAnimating(_ process: CGFloat) {
        refreshView.pullToRefresh(refreshView, progressDidChange: process, direction: direction)
    }
    
    func startAnimating(animated: Bool = true) {
        guard state != .refreshing else { return }

        state = .refreshing
        
        let updateClosure = {
            if self.isPullingDown {
                self.scrollView.contentInset.top += self.pullingHeight
                self.scrollView.contentOffset.y = self.originalContentOffsetY - self.pullingHeight
            } else {
                self.scrollView.contentInset.bottom += self.pullingHeight
                self.scrollView.contentOffset.y += self.pullingHeight
            }
        }
        
        let completionClosure = { (completion: Bool) in
            self.refreshView?.pullToRefreshAnimationDidStart(self.refreshView, direction: self.direction)
            self.action(self.scrollView)
        }
        
        if animated {
            UIView.animate(withDuration: 0.4, animations: updateClosure, completion: completionClosure)
        } else {
            updateClosure()
            completionClosure(true)
        }
    }
    
    open func stopAnimating(animated: Bool = true, scrollToOriginalPosition: Bool = true) {
        guard state != .done else {
            return
        }
        
        state = .done
        
        refreshView?.pullToRefreshAnimationDidEnd(refreshView, direction: direction)
        
        let updateClosure = {
            if scrollToOriginalPosition {
                if self.isPullingDown {
                    self.scrollView.contentOffset.y = self.originalContentOffsetY
                } else {
                    self.scrollView.contentOffset.y -= self.pullingHeight
                }
            }
            
            if self.isPullingDown {
                self.scrollView.contentInset.top -= self.pullingHeight
            } else {
                self.scrollView.contentInset.bottom -= self.pullingHeight
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.4, animations: updateClosure)
        } else {
            updateClosure()
        }
    }
}
