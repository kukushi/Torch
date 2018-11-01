//
//  PullContainerView.swift
//  Torch
//
//  Created by kukushi on 2018/8/2.
//  Copyright © 2018 Xing He. All rights reserved.
//

import UIKit

class PullContainerView: UIView {
    var observer: ScrollObserver?
    private var isObserving = false

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        if newSuperview == nil {
            observer?.stopObserving()
            unobserveAppState()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        // Handle view controller switching
        if window == nil {
            observer?.pauseAnimation()
        } else {
            observer?.resumeAnimation()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isObserving {
            isObserving = true
            observer?.startObserving()
            observingAppState()
        }
    }

    // MARK: Background & Foreground

    private func unobserveAppState() {
        NotificationCenter.default.removeObserver(self)
    }

    private func observingAppState() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(pauseAnimation),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resumeAnimation),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc func pauseAnimation() {
        observer?.pauseAnimation()
    }

    @objc func resumeAnimation() {
        observer?.resumeAnimation()
    }

}
