//
//  PullResponsable.swift
//  Torch
//
//  Created by kukushi on 2018/8/2.
//  Copyright © 2018 Xing He. All rights reserved.
//

import CoreGraphics

public protocol PullResponsable: class {
    func pullToRefreshAnimationDidStart(_ view: RefreshView, direction: PullDirection)
    func pullToRefreshAnimationDidEnd(_ view: RefreshView, direction: PullDirection)
    func pullToRefresh(_ view: RefreshView, progressDidChange progress: CGFloat, direction: PullDirection)
    func pullToRefresh(_ view: RefreshView, stateDidChange state: PullState, direction: PullDirection)
    func preferredSize() -> CGSize
}

extension PullResponsable {
    func pullToRefreshAnimationDidStart(_ view: RefreshView, direction: PullDirection) {}
    func pullToRefreshAnimationDidEnd(_ view: RefreshView, direction: PullDirection) {}
    func pullToRefresh(_ view: RefreshView, progressDidChange progress: CGFloat, direction: PullDirection) {}
    func pullToRefresh(_ view: RefreshView, stateDidChange state: PullState, direction: PullDirection) {}
}
