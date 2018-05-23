//
//  SecondViewController.swift
//  TorchExample
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

class ScrollView: UIScrollView {
    override var contentOffset: CGPoint {
        didSet {
            print("OffsetY", contentOffset.y, "InsetTop", contentInset.top)
        }
    }
}

class SecondViewController: UIViewController {

    @IBOutlet weak var secondScrollView: ScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        secondScrollView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

