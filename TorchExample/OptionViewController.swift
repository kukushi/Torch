//
//  FirstViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

struct AdditionalPullOption {
    var addCount: Int
    var scrollToOriginalPosition: Bool
    var shouldAnimateStop: Bool
}

class OptionViewController: UITableViewController {
    @IBOutlet weak var pullDownSwitch: UISwitch!
    @IBOutlet weak var enableTapticFeedbackSwitch: UISwitch!
    @IBOutlet weak var startsAutomaticallySwitch: UISwitch!
    @IBOutlet weak var keepOriginalFeedbackSwitch: UISwitch!
    @IBOutlet weak var refreshWithoutNewDataSwitch: UISwitch!
    @IBOutlet weak var scrollToOriginalPosition: UISwitch!
    @IBOutlet weak var animatedStopSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 44
        title = "Torch"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushDetail" {
            guard let detailViewController = segue.destination as? DetailTableViewController else {
                return
            }
            var pullOption = PullOption()
            pullOption.enableTapticFeedback = enableTapticFeedbackSwitch.isOn
            pullOption.direction =  pullDownSwitch.isOn ? .down : .up
            pullOption.shouldStartBeforeReachingBottom = startsAutomaticallySwitch.isOn
            pullOption.startBeforeReachingBottomFactor = 0.1

            let newCount = refreshWithoutNewDataSwitch.isOn ? 0 : 50
            let additionalOption = AdditionalPullOption(addCount: newCount,
                                                       scrollToOriginalPosition: scrollToOriginalPosition.isOn,
                                                       shouldAnimateStop: animatedStopSwitch.isOn)

            detailViewController.option = pullOption
            detailViewController.additionalOption = additionalOption
        }
    }
}
