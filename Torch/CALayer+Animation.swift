//
//  CALayer+Animation.swift
//  Torch
//
//  Created by kukushi on 2018/11/1.
//  Copyright © 2018 Xing He. All rights reserved.
//

import QuartzCore

// https://stackoverflow.com/questions/20946481/comprehend-pause-and-resume-animation-on-a-layer
public extension CALayer {
    var isAnimationsPaused: Bool {
        return speed == 0.0
    }

    func pauseAnimations() {
        guard !isAnimationsPaused else {
            return
        }

        // Get layer's time space
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func resumeAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0

        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
