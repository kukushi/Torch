//
//  LineRefreshView.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//


import UIKit
import QuartzCore

public class LineRefreshView: RefreshView {
    
    var color: UIColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) {
        willSet {
            layerLoader.strokeColor = newValue.CGColor
        }
    }
    
    var separatorColor: UIColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0) {
        willSet {
            layerSeparator.strokeColor = newValue.CGColor
        }
    }
    
    public let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .Center
        return label
    }()
    
    private let layerLoader: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 4.0
        layer.strokeEnd = 0.0
        return layer
    }()

    private let layerSeparator: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 1.0
        return layer
    }()
    
    
    
    public var pullToRefreshText = NSLocalizedString("Pull to refresh", comment: "Refresher")
    public var loadingText = NSLocalizedString("Loading ...", comment: "Refresher")
    public var releaseToRefreshText = NSLocalizedString("Release to refresh", comment: "Refresher")
    
    public override func initialize() {
        super.initialize()
        
        addSubview(textLabel)
        let views = ["textLabel": textLabel]
        let formats = ["H:|-(>=10)-[textLabel]-(>=10)-|", "V:|-(>=15,==15@500)-[textLabel]-(>=15,==15@500)-|"]
        let constraints = formats.reduce([AnyObject]()) { constraints, format in
            return constraints + NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: nil, views: views)
            } + [
                NSLayoutConstraint(item: textLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: textLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0)
        ] as! [NSLayoutConstraint]
        addConstraints(constraints)
        
        layer.addSublayer(layerSeparator)
        layer.addSublayer(layerLoader)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let bezierPathLoader = UIBezierPath()
        bezierPathLoader.moveToPoint(CGPoint(x: 0.0, y: frame.height - layerLoader.lineWidth))
        bezierPathLoader.addLineToPoint(CGPoint(x: frame.width, y: frame.height - layerLoader.lineWidth))
        layerLoader.path = bezierPathLoader.CGPath
        
        let bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPoint(x: 0.0, y: frame.height - layerSeparator.lineWidth))
        bezierPathSeparator.addLineToPoint(CGPoint(x: frame.width, y: frame.height - layerSeparator.lineWidth))
        layerSeparator.path = bezierPathSeparator.CGPath
    }
    
    // MARK: - PullToRefreshView methods
    public override func stateChanged(previousState: RefreshState) {
        super.stateChanged(previousState)
        switch previousState {
        case .Pulling:
            textLabel.text = pullToRefreshText
        case .ReadyToRelease:
            textLabel.text = releaseToRefreshText
        case .Refreshing:
            textLabel.text = loadingText
        }
        
//        labelTitle.layoutIfNeeded()
    }
    
    public override func startAnimating() {
        super.startAnimating()
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
    
    public override func progressAnimating(factor: CGFloat) {
        super.progressAnimating(factor)
        layerLoader.strokeEnd = factor
    }
    
    public override func stopAnimating() {
        super.stopAnimating()
        layerLoader.removeAllAnimations()
    }
}