//
//  RefreshView.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public class RefreshView: UIView {
    var action: RefreshAction!
    public var isInsetAdjusted = false
    
    lazy var loading = false
    
    private var contentOffsetY: CGFloat!
    
    private var originalInsetTop: CGFloat = 0
    private var originalContentOffsetY: CGFloat = 0
    
    public enum RefreshState {
        case Pulling
        case ReadyToRelease
        case Refreshing
    }
    
    public private(set) var state: RefreshState = .Pulling {
        didSet {
            stateChanged(state)
        }
    }
    
    var scrollView: UIScrollView! {
        return superview as? UIScrollView
    }
    
    // MARK: Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }

    required public init(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK:
    
    func initialize() {

    }
    
    // MARK:

    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if scrollView != nil {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    override public func didMoveToSuperview() {
        if scrollView != nil {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
            originalInsetTop = scrollView.contentInset.top +  (isInsetAdjusted ? 64 : 0)
            originalContentOffsetY = scrollView.contentOffset.y - (isInsetAdjusted ? 64 : 0)
        }
    }
    
    // MARK: KVO
    
    override public func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let viewHeight = frame.height
        if keyPath == "contentOffset" {
            let offset = scrollView.contentOffset.y + originalInsetTop
            if !loading {
                if scrollView.dragging && offset != 0 {
                    progressAnimating(-offset / viewHeight)
                }
                else if offset <= -viewHeight {
                    
                    startAnimating()
                }
            }
            
        }
    }
    
    // MARK: Animating
    
    func progressAnimating(factor: CGFloat) {
        if factor < 1 {
            state = .Pulling
        }
        else {
            state = .ReadyToRelease
        }
    }
    
    public func startAnimating() {
        state = .Refreshing
        
        loading = true
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            println("\(self.scrollView.contentInset.top) \(self.scrollView.contentOffset.y)" )
            self.scrollView.contentOffset.y = 0
            self.scrollView.contentInset.top += self.frame.height
            println("\(self.scrollView.contentInset.top) \(self.scrollView.contentOffset.y)" )
            }) { (finished) -> Void in
                self.action()
        }
    }
    
    
    public func stopAnimating() {
        
        loading = false
        
        //scrollView.bounces = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            println("\(self.scrollView.contentInset.top) \(self.scrollView.contentOffset.y)" )
            self.scrollView.contentOffset.y = self.originalContentOffsetY
            self.scrollView.contentInset.top -= self.frame.height
           println("\(self.scrollView.contentInset.top) \(self.scrollView.contentOffset.y)" )
        })
    }
    
    public func stateChanged(previousState: RefreshState) {
        
    }
}