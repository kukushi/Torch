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
    }

    private func addPullToRefresher() {
        let width = UIScreen.main.bounds.width
        let refreshView = PlainRefreshView(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        refreshView.lineColor = UIColor.red

        tableView.addPullToRefresh(refreshView, action: { (scrollView) in
            OperationQueue().addOperation {
                sleep(4)
                OperationQueue.main.addOperation {
                    scrollView.stopRefresh()
                }
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addPullToRefresher()
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
