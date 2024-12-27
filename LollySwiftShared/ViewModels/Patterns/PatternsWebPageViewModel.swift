//
//  PatternsWebPageViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PatternsWebPageViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrPatterns = [MPattern]()
    var currentPatternIndex_ = BehaviorRelay(value: 0)
    var currentPatternIndex: Int { get { currentPatternIndex_.value } set { currentPatternIndex_.accept(newValue) } }
    var currentPattern: MPattern { arrPatterns[currentPatternIndex] }
    func next(_ delta: Int) {
        currentPatternIndex = (currentPatternIndex + delta + arrPatterns.count) % arrPatterns.count
    }

    init(settings: SettingsViewModel, arrPatterns: [MPattern], currentPatternIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrPatterns = arrPatterns
        super.init()
        self.currentPatternIndex = currentPatternIndex
    }
}
