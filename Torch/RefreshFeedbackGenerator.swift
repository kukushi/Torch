//
//  RefreshFeedback.swift
//  Torch
//
//  Created by kukushi on 2018/6/16.
//  Copyright © 2018 Xing He. All rights reserved.
//

import AudioToolbox
import UIKit

public class RefreshFeedbackGenerator {
    private let canUseHapticFeedback: Bool
    private var _feedbackGenerator: Any? = nil
    @available(iOS 10.0, *) private var impactGenerator: UIImpactFeedbackGenerator? {
        get {
            if _feedbackGenerator == nil {
                _feedbackGenerator = UIImpactFeedbackGenerator()
            }
            return _feedbackGenerator as? UIImpactFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    init() {
        let device = UIDevice.current
        if let supportLevel = device.value(forKey: "_feedbackSupportLevel") as? NSNumber {
            canUseHapticFeedback = (supportLevel.intValue == 2)
        } else {
            canUseHapticFeedback = false
        }
    }
    
    func prepare() {
        if #available(iOS 10.0, *), canUseHapticFeedback {
            impactGenerator?.prepare()
        }
    }
    
    func reset() {
        if #available(iOS 10.0, *), canUseHapticFeedback {
            impactGenerator = nil
        }
    }
    
    func generate() {
        if #available(iOS 10.0, *), canUseHapticFeedback {
            impactGenerator?.impactOccurred()
        } else {
            AudioServicesPlaySystemSound(1519)
        }
    }
}
