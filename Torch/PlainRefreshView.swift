//
//  PlainRefreshView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

public class PlainRefreshView: UIView {
    
    public var pullToRefreshText = NSLocalizedString("Pull to refresh", comment: "Refresher")
    public var loadingText = NSLocalizedString("Loading ...", comment: "Refresher")
    public var releaseToRefreshText = NSLocalizedString("Release to refresh", comment: "Refresher")
    
    public var lineColor: UIColor {
        set {
            layerLoader.strokeColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layerLoader.strokeColor!)
        }
    }
    
    public let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray()
        return label
    }()
    
    private let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.blue().cgColor
        layer.lineWidth = 4.0
        layer.strokeEnd = 0.0
        layer.lineCap = kCALineCapRound
        return layer
    }()
    
    private let layerSeparator: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray().cgColor
        layer.lineWidth = 1.0 / UIScreen.main().scale
        return layer
    }()
    
    // MARK: Initalization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initalize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initalize()
    }
    
    private func initalize() {
        addSubview(textLabel)
        
        layer.addSublayer(layerSeparator)
        layer.addSublayer(layerLoader)
    }
    
    // MARK:
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5 - 6)
        
        let bezierPathLoader = UIBezierPath()
        bezierPathLoader.move(to: CGPoint(x: 0.0, y: frame.height - layerLoader.lineWidth))
        bezierPathLoader.addLine(to: CGPoint(x: frame.width, y: frame.height - layerLoader.lineWidth))
        layerLoader.path = bezierPathLoader.cgPath
        
        let bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.move(to: CGPoint(x: 0.0, y: frame.height - layerSeparator.lineWidth))
        bezierPathSeparator.addLine(to: CGPoint(x: frame.width, y: frame.height - layerSeparator.lineWidth))
        layerSeparator.path = bezierPathSeparator.cgPath
    }
}

extension PlainRefreshView: PullToRefreshViewDelegate {
    public func pullToRefresh(_ view: RefreshObserverView, stateDidChange state: PullToRefreshViewState) {
        switch state {
        case .pulling:
            textLabel.text = pullToRefreshText
        case .readyToRelease:
            textLabel.text = releaseToRefreshText
        case .refreshing:
            textLabel.text = loadingText
        case .done:
            textLabel.text = ""
        }
    }
    
    public func pullToRefreshAnimationDidStart(_ view: RefreshObserverView) {
        let pathAnimationEnd = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationEnd.duration = 0.5
        pathAnimationEnd.repeatCount = 100
        pathAnimationEnd.autoreverses = true
        pathAnimationEnd.fromValue = 0.2
        pathAnimationEnd.toValue = 1.0
        layerLoader.add(pathAnimationEnd, forKey: "strokeEndAnimation")
        
        let pathAnimationStart = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationStart.duration = 0.5
        pathAnimationStart.repeatCount = 100
        pathAnimationStart.autoreverses = true
        pathAnimationStart.fromValue = 0.0
        pathAnimationStart.toValue = 0.8
        layerLoader.add(pathAnimationStart, forKey: "strokeStartAnimation")
    }
    
    public func pullToRefresh(_ view: RefreshObserverView, progressDidChange progress: CGFloat) {
        layerLoader.strokeEnd = progress
    }
    
    public func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView) {
        layerLoader.strokeEnd = 0
        layerLoader.removeAllAnimations()
    }
}
