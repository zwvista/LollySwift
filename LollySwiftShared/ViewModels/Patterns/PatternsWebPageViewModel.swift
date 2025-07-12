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
    var selectedPatternIndex_ = BehaviorRelay(value: 0)
    var selectedPatternIndex: Int { get { selectedPatternIndex_.value } set { selectedPatternIndex_.accept(newValue) } }
    var selectedPattern: MPattern { arrPatterns[selectedPatternIndex] }
    func next(_ delta: Int) {
        selectedPatternIndex = (selectedPatternIndex + delta + arrPatterns.count) % arrPatterns.count
    }

    init(settings: SettingsViewModel, arrPatterns: [MPattern], selectedPatternIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrPatterns = arrPatterns
        super.init()
        self.selectedPatternIndex = selectedPatternIndex
    }
}
