//
//  CALayer+Animation.swift
//  Torch
//
//  Created by kukushi on 2018/11/1.
//  Copyright © 2018 Xing He. All rights reserved.
//

import QuartzCore

public extension CALayer {
    var isAnimationsPaused: Bool {
        return speed == 0.0
    }

    func pauseAnimations() {
        if !isAnimationsPaused {
            let currentTime = CACurrentMediaTime()
            let pausedTime = convertTime(currentTime, from: nil)
            speed = 0.0
            timeOffset = pausedTime
        }
    }

    func resumeAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = CACurrentMediaTime()
        let timeSincePause = convertTime(currentTime, from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
