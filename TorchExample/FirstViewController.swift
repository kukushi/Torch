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
        let width = UIScreen.main.bounds.width
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        refreshView.lineColor = UIColor.red
        
        tableView.addPullToRefresh(refreshView, action: { (scrollView) in
            OperationQueue().addOperation {
                sleep(3)
                OperationQueue.main.addOperation {
                    scrollView.stopRefresh()
                }
            }
        })
    }
    
    private func addPullUpToRefresher() {
        let width = UIScreen.main.bounds.width
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        refreshView.lineColor = UIColor.red
        
        tableView.addPullToRefresh(refreshView, direction: .up) { (scrollView) in
            OperationQueue().addOperation {
                self.count += 3
                sleep(3)
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    scrollView.stopRefresh(.up)
                }
            }
        }
        tableView.pullDownRefreshView?.enableTapticFeedback = true
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
