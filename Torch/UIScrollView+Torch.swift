//
//  UIScrollView+Torch.swift
//  Torch
//
//  Created by kukushi on 3/30/15.
//  Copyright (c) 2015 Xing He. All rights reserved.
//

import UIKit

private var torchKey = 0

public extension UIScrollView {
    // swiftlint:disable:next identifier_name
    public var tr: TorchControl {
        if let control = objc_getAssociatedObject(self, &torchKey) as? TorchControl {
            return control
        } else {
            let control = TorchControl(baseView: self)
            objc_setAssociatedObject(self, &torchKey, control, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return control
        }
    }
}
