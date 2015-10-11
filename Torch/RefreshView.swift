//
//  RefreshView.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

public class RefreshView: UIView {
    var action: RefreshAction?
    var pullUpAction: RefreshAction?
    
    public var isInsetAdjusted = false
    
    lazy var loading = false
    
    var triggerd = false
    
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

    required public init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK:
    
    func initialize() {
        print("f")
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
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let viewHeight = frame.height
        if keyPath == "contentOffset" {
            let offset = scrollView.contentOffset.y + originalInsetTop
            
            if !loading {
                
//                print("\(offset) - \(scrollView.contentSize.height - scrollView.frame.height)")
                if scrollView.dragging && offset != 0 {
//                    print("Noew")
                    progressAnimating(-offset / viewHeight)
                }
                else if viewHeight != 0 && offset < -viewHeight {
                    startAnimating()
                }
                else if offset > scrollView.contentSize.height - scrollView.frame.height && !triggerd {
                    triggerd = true
                    pullUpAction?()
                }
                else if offset < scrollView.contentSize.height - scrollView.frame.height && triggerd {
                    triggerd = false
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
            self.scrollView.contentOffset.y = 0
            self.scrollView.contentInset.top += self.frame.height
            
            }) { (finished) -> Void in
                self.action?()
        }
    }
    
    
    public func stopAnimating() {
        
        loading = false
        
        //scrollView.bounces = true
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.scrollView.contentOffset.y = self.originalContentOffsetY
            self.scrollView.contentInset.top -= self.frame.height
        })
    }
    
    public func completeLoading() {
        loading = false
    }
    
    public func stateChanged(previousState: RefreshState) {
        
    }
}