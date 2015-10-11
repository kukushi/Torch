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
    
    var count = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let refreshView = LineRefreshView()
//        refreshView.isInsetAdjusted = true
        tableView.addPullDownRefresher(refreshView, action: { () -> Void in
            NSOperationQueue().addOperationWithBlock {
                sleep(4)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.stopRefresh()
                    
                    print("Inset Top \(self.tableView.contentInset.top)")
                    print("Offset Y \(self.tableView.contentOffset.y)")
                }
            }
            
        })
        
        tableView.addPullUpRefresher(LineRefreshView()) { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.tableView.completeLoading()
                
                self.count += 10
                self.tableView.reloadData()
            }
        }
        
        print("Inset Top \(tableView.contentInset.top)")
        print("Offset Y \(tableView.contentOffset.y)")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
