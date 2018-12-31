//
//  PullResponsable.swift
//  Torch
//
//  Created by kukushi on 2018/8/2.
//  Copyright © 2018 Xing He. All rights reserved.
//

import CoreGraphics

public protocol PullResponsable: class {
    func pullToRefreshAnimationDidPause(_ view: RefreshView, direction: PullDirection)
    func pullToRefreshAnimationDidResume(_ view: RefreshView, direction: PullDirection)
    func pullToRefreshAnimationDidStart(_ view: RefreshView, direction: PullDirection)
    func pullToRefreshAnimationDidEnd(_ view: RefreshView, direction: PullDirection)
    func pullToRefreshAnimationDidFinished(_ view: RefreshView, direction: PullDirection, animated: Bool)
    func pullToRefresh(_ view: RefreshView, progressDidChange progress: CGFloat, direction: PullDirection)
    func pullToRefresh(_ view: RefreshView, stateDidChange state: PullState, direction: PullDirection)

    func preferredSize() -> CGSize
}

public extension PullResponsable {
    func pullToRefreshAnimationDidStart(_ view: RefreshView, direction: PullDirection) {}
    func pullToRefreshAnimationDidEnd(_ view: RefreshView, direction: PullDirection) {}
    func pullToRefreshAnimationDidFinished(_ view: RefreshView, direction: PullDirection, animated: Bool) {}
    func pullToRefresh(_ view: RefreshView, progressDidChange progress: CGFloat, direction: PullDirection) {}
    func pullToRefresh(_ view: RefreshView, stateDidChange state: PullState, direction: PullDirection) {}
}
