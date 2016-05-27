//
//  FirstViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

class FirstViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var count = 7

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Torch"
        
        let width = UIScreen.mainScreen().bounds.width
        let refreshView = PlainRefreshView(frame: CGRectMake(0, 0, width, 44))
        refreshView.lineColor = UIColor.redColor()
        tableView.refreshView?.isInsetAdjusted = automaticallyAdjustsScrollViewInsets
        tableView.addPullToRefresh(refreshView, action: { (scrollView) in
            NSOperationQueue().addOperationWithBlock {
                sleep(4)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    scrollView.stopRefresh()
                }
            }
        })
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
