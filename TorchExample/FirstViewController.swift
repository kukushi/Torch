//
//  FirstViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

public class XX: UIView, PullToRefreshViewDelegate {
    
    public func pullToRefresh(view: RefreshObserverView, stateDidChange state: PullToRefreshViewState) {
        
    }
    
    public func pullToRefreshAnimationDidStart(view: RefreshObserverView) {
        
    }
    
    public func pullToRefresh(view: RefreshObserverView, progressDidChange progress: CGFloat) {
        
    }
    
    public func pullToRefreshAnimationDidEnd(view: RefreshObserverView) {
        
    }
}


class FirstViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var count = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshView?.isInsetAdjusted = automaticallyAdjustsScrollViewInsets
        tableView.addPullToRefresh { (scrollView) -> Void in
            NSOperationQueue().addOperationWithBlock {
                sleep(4)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    scrollView.stopRefresh()
                }
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
}
