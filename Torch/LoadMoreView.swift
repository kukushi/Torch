//
//  LineRefreshView.swift
//  Torch
//
//  Created by kukushi on 9/19/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

public class LoadMoreView: UIView {
    var action: RefreshAction!
    
    var scrollView: UIScrollView! {
        return superview as? UIScrollView
    }
    
    override public func didMoveToSuperview() {
        if scrollView != nil {
            scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        }
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if scrollView != nil {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
    }
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        let viewHeight = frame.height
        if keyPath == "contentOffset" {
            print("\(scrollView.contentOffset.y)")
        }
    }
}