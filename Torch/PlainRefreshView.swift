//
//  PlainRefreshView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

open class PlainRefreshView: UIView {

    private var isAnimating = false

    open var lineColor: UIColor {
        set {
            layerLoader.strokeColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layerLoader.strokeColor!)
        }
    }

    private var rotationAnimation: CABasicAnimation {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float(Double.pi * 2.0)
        rotationAnimation.duration = 1
        rotationAnimation.repeatCount = HUGE
        return rotationAnimation
    }

    fileprivate let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.red.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 3
        layer.strokeEnd = 0.0
        layer.lineCap = CAShapeLayerLineCap.round
        return layer
    }()

    // MARK: Initialization

    override public init(frame: CGRect) {
        super.init(frame: frame)

        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initialize()
    }

    fileprivate func initialize() {
        layer.addSublayer(layerLoader)
    }

    // MARK: 

    open override func layoutSubviews() {
        super.layoutSubviews()

        let bezierPathLoader = UIBezierPath()
        let size = frame.size
        let startAngle = CGFloat(-Double.pi * 0.6)
        bezierPathLoader.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                radius: (size.width - 4) / 2,
                                startAngle: startAngle,
                                endAngle: CGFloat(2 * Double.pi) + startAngle,
                                clockwise: true)

        layerLoader.path = bezierPathLoader.cgPath
    }
}

extension PlainRefreshView: PullResponsable {

    public func preferredSize() -> CGSize {
        return CGSize(width: 28, height: 28)
    }

    public func pullToRefreshAnimationDidStart(_ view: RefreshView, direction: PullDirection) {
        layerLoader.strokeStart = 0.2
        layerLoader.strokeEnd = 1

        isAnimating = true
        layer.add(rotationAnimation, forKey: "rotating")
    }

    public func pullToRefreshAnimationDidPause(_ view: RefreshView, direction: PullDirection) {
        // all animation are removed from the layer when app enter background or moving to nil windows
        layer.removeAllAnimations()

        if isAnimating {
            layer.pauseAnimations()
        }
    }

    public func pullToRefreshAnimationDidResume(_ view: RefreshView, direction: PullDirection) {
        if isAnimating {
            layer.add(rotationAnimation, forKey: "rotating")
            layer.resumeAnimations()
        }
    }

    public func pullToRefresh(_ view: RefreshView, progressDidChange progress: CGFloat, direction: PullDirection) {
        let tweak = min(max(progress - 0.3, 0), 0.7)
        layerLoader.strokeStart = tweak / 3.0
        layerLoader.strokeEnd = tweak + 0.3
    }

    public func pullToRefreshAnimationDidEnd(_ view: RefreshView, direction: PullDirection) {
        layer.removeAllAnimations()
        isAnimating = false
    }

    public func pullToRefreshAnimationDidFinished(_ view: RefreshView, direction: PullDirection, animated: Bool) {
        if animated {
            layerLoader.strokeEnd = 0
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layerLoader.strokeEnd = 0
            CATransaction.commit()
        }
    }
}
