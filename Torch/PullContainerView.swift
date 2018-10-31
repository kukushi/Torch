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
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if !isObserving {
            isObserving = true
            observer?.startObserving()
        }
    }

}
