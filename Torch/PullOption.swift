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
    case down
    case up
}

public struct PullOption {
    public var direction = PullDirection.down
    public var areaHeight: CGFloat = 44
    public var enableTapticFeedback = false
    public var topPadding: CGFloat = 0
    
    public var startBeforeReachingBottom = false
    public var startBeforeReachingBottomOffset: CGFloat = 0
    
    public init() {}
}
