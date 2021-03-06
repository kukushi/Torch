//
//  FirstViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit
import Torch

struct AddtionalPullOption {
    var addCount: Int
}

class OptionViewController: UITableViewController {
    @IBOutlet weak var pullDownSwitch: UISwitch!
    @IBOutlet weak var enableTapticFeedbackSwitch: UISwitch!
    @IBOutlet weak var startsAutomaticallySwitch: UISwitch!
    @IBOutlet weak var keepOriginalFeedbackSwitch: UISwitch!
    @IBOutlet weak var refreshWithoutNewDataSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

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
            pullOption.startBeforeReachingBottom = startsAutomaticallySwitch.isOn
            pullOption.startBeforeReachingBottomOffset = 200

            let newCount = refreshWithoutNewDataSwitch.isOn ? 0 : 3
            var additionalOption = AddtionalPullOption(addCount: newCount)

            detailViewController.option = pullOption
            detailViewController.addtionalOption = additionalOption
        }
    }
}
