//
//  MReviewOptions.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxRelay

class MReviewOptions: NSObject {
    var mode: ReviewMode = .reviewAuto
    var interval = 5
    var shuffled = false
    var groupCount = 1
    var groupSelected = 1
    var speakingEnabled = true
    var reviewCount = 10
    var onRepeat = true
}

class MReviewOptionsEdit {
    let mode: BehaviorRelay<Int>
    let modeString: BehaviorRelay<String>
    let interval: BehaviorRelay<Int>
    let shuffled: BehaviorRelay<Bool>
    let groupCount: BehaviorRelay<Int>
    let groupSelected: BehaviorRelay<Int>
    let speakingEnabled: BehaviorRelay<Bool>
    let reviewCount: BehaviorRelay<Int>
    let onRepeat: BehaviorRelay<Bool>

    init(x: MReviewOptions) {
        mode = BehaviorRelay(value: x.mode.rawValue)
        modeString = BehaviorRelay(value: SettingsViewModel.reviewModes[x.mode.rawValue])
        interval = BehaviorRelay(value: x.interval)
        shuffled = BehaviorRelay(value: x.shuffled)
        groupCount = BehaviorRelay(value: x.groupCount)
        groupSelected = BehaviorRelay(value: x.groupSelected)
        speakingEnabled = BehaviorRelay(value: x.speakingEnabled)
        reviewCount = BehaviorRelay(value: x.reviewCount)
        onRepeat = BehaviorRelay(value: x.onRepeat)
    }
    
    func save(to x: MReviewOptions) {
        x.mode = ReviewMode(rawValue: mode.value)!
        x.interval = interval.value
        x.shuffled = shuffled.value
        x.groupCount = groupCount.value
        x.groupSelected = groupSelected.value
        x.speakingEnabled = speakingEnabled.value
        x.reviewCount = reviewCount.value
        x.onRepeat = onRepeat.value
    }
}
