//
//  PullOption.swift
//  Torch
//
//  Created by kukushi on 2018/8/2.
//  Copyright © 2018 Xing He. All rights reserved.
//

import UIKit

public typealias RefreshView = UIView & PullResponsable

public typealias RefreshAction = (UIScrollView) -> Void

public enum PullState {
    case pulling
    case readyToRelease
    case refreshing
    case cancel
    case done
}

public enum PullDirection {
    /// Pull down to refresh
    case down

    /// Pull up to refresh
    case up
}

public struct PullOption {
    public var direction = PullDirection.down
    public var areaHeight: CGFloat = 44
    public var enableTapticFeedback = false
    public var topPadding: CGFloat = 0

    public var shouldStartBeforeReachingBottom = false
    public var startBeforeReachingBottomFactor: CGFloat = 0.1 {
        didSet {
            guard startBeforeReachingBottomFactor > 0 && startBeforeReachingBottomFactor < 1 else {
                preconditionFailure("`startBeforeReachingBottomFactor` should be range 0 to 1.")
            }
        }
    }

    // Make the initializer public
    public init() {}
}
