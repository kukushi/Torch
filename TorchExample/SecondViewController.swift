//
//  SecondViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

class SecondViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var count = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addPullUpToRefresher()

    }

    private func addPullUpToRefresher() {
        let refreshView = PlainRefreshView()
        refreshView.lineColor = UIColor(red: 1.00, green: 0.80, blue: 0.00, alpha: 1.00)

        var option = PullOption()
        option.direction = .up
        option.enableTapticFeedback = true

        tableView.addPullToRefresh(refreshView, option: option, action: { [unowned self] (scrollView) in
            OperationQueue().addOperation {
                let newRows = arc4random() % 2 == 0 ? 3 : 0
                self.count += newRows
                sleep(200)
                OperationQueue.main.addOperation {
                    if newRows != 0 {
                        let cellNumber = self.tableView.numberOfRows(inSection: 0)
                        let addedIndexs = (cellNumber..<(cellNumber + newRows)).map { IndexPath(row: $0, section: 0) }
                        self.tableView.insertRows(at: addedIndexs, with: .none)
                    }

                    scrollView.stopRefresh(.up, scrollToOriginalPosition: newRows == 0 ? true : false)
                }
            }
        })
    }

}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = "\((indexPath as NSIndexPath).row)"
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
}
