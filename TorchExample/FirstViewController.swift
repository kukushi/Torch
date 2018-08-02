//
//  FirstViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

class TableView: UITableView {
    override var contentOffset: CGPoint {
        didSet {
//            print("OffsetY", contentOffset.y, "InsetTop", contentInset.top)
//            print("ViewHeight", frame.height, "ContentHeight", contentSize.height)
        }
    }
}

class FirstViewController: UIViewController {
    @IBOutlet weak var tableView: TableView!
    
    var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Torch"
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addPullToRefresher()
        addPullUpToRefresher()
    }
    
    private func addPullToRefresher() {
        let refreshView = PlainRefreshView()
        refreshView.lineColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.00)
        
        var option = PullOption()
        option.topPadding = 20
        
        tableView.addPullToRefresh(refreshView, option: option, action: { (scrollView) in
            OperationQueue().addOperation {
                sleep(3)
                OperationQueue.main.addOperation {
                    scrollView.stopRefresh()
                }
            }
        })
    }
    
    private func addPullUpToRefresher() {
        let refreshView = PlainRefreshView()
        refreshView.lineColor = UIColor(red:1.00, green:0.80, blue:0.00, alpha:1.00)
        
        var option = PullOption()
        option.direction = .up
        option.enableTapticFeedback = true
        
        tableView.addPullToRefresh(refreshView, option: option, action: { (scrollView) in
            OperationQueue().addOperation {
                self.count += 3
                sleep(3)
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    scrollView.stopRefresh(.up, scrollToOriginalPosition: false)
                }
            }
        })
    }
}

extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
}
