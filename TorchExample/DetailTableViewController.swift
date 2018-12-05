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

    var option: PullOption!
    var additionalOption: AddtionalPullOption!

    var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Torch"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addPullToRefresher()
    }

    private func addPullToRefresher() {
        let refreshView = PlainRefreshView()
        refreshView.lineColor = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.00)

        tableView.tr.addPullToRefresh(refreshView, option: option, action: { (scrollView) in
            OperationQueue().addOperation {
                sleep(2)
                let newCount = self.count + self.additionalOption.addCount
                OperationQueue.main.addOperation {
                    if self.additionalOption.addCount > 0 {
                        let insertedIndexes = (self.count..<newCount).map { IndexPath(item: $0, section: 0) }
                        self.count = newCount
                        self.tableView.insertRows(at: insertedIndexes, with: .none)
                    }
                    scrollView.tr.stopRefresh(self.option.direction,
                                           animated: self.additionalOption.shouldAnimateStop,
                                           scrollToOriginalPosition: self.additionalOption.scrollToOriginalPosition)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
