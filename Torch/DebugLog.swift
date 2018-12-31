//
//  DebugLog.swift
//  Torch
//
//  Created by kukushi on 2018/12/31.
//  Copyright © 2018 Xing He. All rights reserved.
//

import Foundation

func debugLog(_ message: @autoclosure () -> String) {
    assert({ () -> Bool in
        print(message())
        return true
    }())
}
