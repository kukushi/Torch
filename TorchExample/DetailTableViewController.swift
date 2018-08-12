//
//  DetailTableViewController.swift
//  TorchExample
//
//  Created by kukushi on 2018/8/2.
//  Copyright © 2018 Xing He. All rights reserved.
//

import UIKit
import Torch

class DetailTableViewController: UITableViewController {

    var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Torch"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addPullToRefresher()
        addPullUpToRefresher()
    }

    private func addPullToRefresher() {
        let refreshView = PlainRefreshView()
        refreshView.lineColor = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.00)

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
        refreshView.lineColor = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.00)

        var option = PullOption()
        option.direction = .up
        option.enableTapticFeedback = true
        option.startBeforeReachingBottom = true
        option.startBeforeReachingBottomOffset = 30

        tableView.addPullToRefresh(refreshView, option: option, action: {[unowned self] (scrollView) in
            OperationQueue().addOperation {
                self.count += arc4random() % 2 == 0 ? 3 : 0
                sleep(3)
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    scrollView.stopRefresh(.up, scrollToOriginalPosition: false)
                }
            }
        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
}
