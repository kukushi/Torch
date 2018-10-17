//
//  RefreshObserverView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

class ScrollObserver: NSObject {
    let option: PullOption
    let action: RefreshAction

    weak var refreshView: RefreshView?
    weak var containerView: UIView?

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

    private var observingContentOffsetToken: NSKeyValueObservation?
    private var observingContentSizeToken: NSKeyValueObservation?

    open private(set) var state: PullState = .done {
        didSet {
            guard oldValue != state else {
                return
            }
            stateChanged(from: oldValue, to: state)
        }
    }

    private var appropriateContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return scrollView.adjustedContentInset
        } else {
            return scrollView.contentInset
        }
    }

    var scrollView: UIScrollView {
        return containerView?.superview as! UIScrollView
    }

    init(refreshView: RefreshView, option: PullOption, action: @escaping RefreshAction) {
        self.refreshView = refreshView
        self.option = option
        self.action = action
    }

    deinit {
        cancelKVO()
    }

    func stopObserving() {
        cancelKVO()
    }

    private func cancelKVO() {
        if #available(iOS 11.0, *) {
            observingContentSizeToken = nil
            observingContentOffsetToken = nil
        } else {
            // NSKeyValueObservation crash on deinit on iOS 10
            // https://bugs.swift.org/browse/SR-5816
            guard containerView != nil else {
                return
            }

            if let scrollView = containerView?.superview {
                if let observingContentSizeToken = observingContentSizeToken {
                    scrollView.removeObserver(observingContentSizeToken, forKeyPath: "contentSize")
                }
                if let observingContentOffsetToken = observingContentOffsetToken {
                    scrollView.removeObserver(observingContentOffsetToken, forKeyPath: "contentOffset")
                }
            }
            observingContentSizeToken = nil
            observingContentOffsetToken = nil
        }
    }

    func startObserving() {
        if containerView?.superview == nil {
            return
        }

        guard containerView?.superview is UIScrollView else {
            fatalError("Refreher can only be used in UIScrollView and it's subclasses.")
        }

        observingContentOffsetToken = scrollView.observe(\.contentOffset,
                                                         options: .new) { [weak self] (_, _) in
            guard let strongSelf = self else { return }
            strongSelf.observingContentOffsetChanges()
        }

        originalContentOffsetY = scrollView.contentOffset.y

        if !isPullingDown {
            observingContentSizeToken = scrollView.observe(\.contentSize,
                                                           options: .new) { [weak self] (_, _) in
                guard let strongSelf = self else { return }
                strongSelf.observingContentSizeChanges()
            }
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
            let offset = scrollView.contentOffset.y + appropriateContentInset.top
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

                    processAnimatingAndState(process)
                }
            }
        case .up:
            let contentHeight = scrollView.contentSize.height
            let containerHeight = scrollView.frame.height
            if contentHeight < containerHeight {
                return
            }

            let offset = scrollView.contentOffset.y - appropriateContentInset.bottom
            let bottfomOffset = containerHeight + offset - contentHeight

            // Starts animation automatically and remember this location to prevent infinite animation
            if option.startBeforeReachingBottom &&
                state != .refreshing &&
                leastRefreshingHeight != scrollView.contentSize.height {
                if bottfomOffset > -option.startBeforeReachingBottomOffset {
                    leastRefreshingHeight = scrollView.contentSize.height
                    startAnimating()
                }
                return
            }

            if scrollView.isDragging {
                if bottfomOffset > 0 {
                    let process = bottfomOffset / viewHeight
                    processAnimatingAndState(process)
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
        guard let refreshView = refreshView else { return }
        refreshView.pullToRefresh(refreshView, stateDidChange: state, direction: direction)
    }

    func processAnimatingAndState(_ process: CGFloat) {
        state = process < 1 ? .pulling : .readyToRelease

        guard let refreshView = refreshView else { return }
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
            guard let refreshView = self.refreshView else {
                return
            }

            refreshView.pullToRefreshAnimationDidStart(refreshView, direction: self.direction)
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
        guard state == .refreshing else {
            return
        }

        state = .done

        guard let refreshView = self.refreshView else {
            return
        }

        refreshView.pullToRefreshAnimationDidEnd(refreshView, direction: direction)

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
            UIView.animate(withDuration: 0.4, animations: updateClosure) { (_) in
                guard let refreshView = self.refreshView else {
                    return
                }
                refreshView.pullToRefreshAnimationDidFinished(refreshView, direction: self.direction)
            }
        } else {
            updateClosure()
            refreshView.pullToRefreshAnimationDidFinished(refreshView, direction: direction)
        }
    }
}
