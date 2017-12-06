//
//  PlainRefreshView.swift
//  Torch
//
//  Created by Xing He on 3/19/16.
//  Copyright © 2016 Xing He. All rights reserved.
//

import UIKit

open class PlainRefreshView: UIView {
    
    open var pullToRefreshText = NSLocalizedString("Pull to refresh", comment: "Refresher")
    open var loadingText = NSLocalizedString("Loading ...", comment: "Refresher")
    open var releaseToRefreshText = NSLocalizedString("Release to refresh", comment: "Refresher")
    
    open var lineColor: UIColor {
        set {
            layerLoader.strokeColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layerLoader.strokeColor!)
        }
    }
    
    open let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        return label
    }()
    
    fileprivate let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.blue.cgColor
        layer.lineWidth = 4.0
        layer.strokeEnd = 0.0
        layer.lineCap = kCALineCapRound
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
    
    fileprivate func initalize() {
        addSubview(textLabel)

        layer.addSublayer(layerLoader)
    }
    
    // MARK:
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5 - 6)
        
        let bezierPathLoader = UIBezierPath()
        bezierPathLoader.move(to: CGPoint(x: 0.0, y: frame.height - layerLoader.lineWidth))
        bezierPathLoader.addLine(to: CGPoint(x: frame.width, y: frame.height - layerLoader.lineWidth))
        layerLoader.path = bezierPathLoader.cgPath
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
        case .cancel:
            layerLoader.strokeEnd = 0
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
        layerLoader.strokeEnd = min(progress, 1)
    }
    
    public func pullToRefreshAnimationDidEnd(_ view: RefreshObserverView) {
        layerLoader.strokeEnd = 0
        layerLoader.removeAllAnimations()
    }
}
