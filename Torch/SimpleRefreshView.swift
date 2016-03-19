//
//  PlainRefreshView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

public class PlainRefreshView: UIView, PullToRefreshViewDelegate {
    
    public var pullToRefreshText = NSLocalizedString("Pull to refresh", comment: "Refresher")
    public var loadingText = NSLocalizedString("Loading ...", comment: "Refresher")
    public var releaseToRefreshText = NSLocalizedString("Release to refresh", comment: "Refresher")
    
    public let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        return label
    }()
    
    private let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.grayColor().CGColor
        layer.lineWidth = 4.0
        layer.strokeEnd = 0.0
        return layer
    }()
    
    private let layerSeparator: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.grayColor().CGColor
        layer.lineWidth = 1.0
        return layer
    }()
    
    // MARK:
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        textLabel.font = UIFont.systemFontOfSize(16)
        textLabel.sizeToFit()
        addSubview(textLabel)
        
        layer.addSublayer(layerSeparator)
        layer.addSublayer(layerLoader)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.center = CGPointMake(frame.width * 0.5, frame.height * 0.5 - 6)
        
        let bezierPathLoader = UIBezierPath()
        bezierPathLoader.moveToPoint(CGPoint(x: 0.0, y: frame.height - layerLoader.lineWidth))
        bezierPathLoader.addLineToPoint(CGPoint(x: frame.width, y: frame.height - layerLoader.lineWidth))
        layerLoader.path = bezierPathLoader.CGPath
        
        let bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPoint(x: 0.0, y: frame.height - layerSeparator.lineWidth))
        bezierPathSeparator.addLineToPoint(CGPoint(x: frame.width, y: frame.height - layerSeparator.lineWidth))
        layerSeparator.path = bezierPathSeparator.CGPath
    }
    
    public func pullToRefresh(view: RefreshObserverView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .Pulling:
            textLabel.text = pullToRefreshText
        case .ReadyToRelease:
            textLabel.text = releaseToRefreshText
        case .Refreshing:
            textLabel.text = loadingText
        }
    }
    
    public func pullToRefreshAnimationDidStart(view: RefreshObserverView) {
        let pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 0.2
        pathAnimationEnd.toValue = 1.0
        layerLoader.addAnimation(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        let pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0.0
        pathAnimationStart.toValue = 0.8
        layerLoader.addAnimation(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    public func pullToRefresh(view: RefreshObserverView, progressDidChange progress: CGFloat) {
        layerLoader.strokeEnd = progress
    }
    
    public func pullToRefreshAnimationDidEnd(view: RefreshObserverView) {
        layerLoader.strokeEnd = 0
        layerLoader.removeAllAnimations()
    }
}