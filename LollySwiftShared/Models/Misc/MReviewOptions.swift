//
//  MReviewOptions.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxRelay

enum ReviewMode: Int {
    case reviewAuto
    case reviewManual
    case test
    case textbook
}

class MReviewOptions: NSObject {
    var mode: ReviewMode = .reviewAuto
    var interval = 5
    var shuffled = false
    var groupCount = 1
    var groupSelected = 1
    var speakingEnabled = true
    var reviewCount = 10
    var onRepeat = true
    var moveForward = true
}

class MReviewOptionsEdit {
    let mode_: BehaviorRelay<Int>
    var mode: Int { get { mode_.value } set { mode_.accept(newValue) } }
    let modeString_: BehaviorRelay<String>
    var modeString: String { get { modeString_.value } set { modeString_.accept(newValue) } }
    let interval: BehaviorRelay<Int>
    let shuffled: BehaviorRelay<Bool>
    let groupCount: BehaviorRelay<Int>
    let groupSelected: BehaviorRelay<Int>
    let speakingEnabled: BehaviorRelay<Bool>
    let reviewCount: BehaviorRelay<Int>
    let onRepeat: BehaviorRelay<Bool>
    let moveForward: BehaviorRelay<Bool>

    init(x: MReviewOptions) {
        mode_ = BehaviorRelay(value: x.mode.rawValue)
        modeString_ = BehaviorRelay(value: SettingsViewModel.reviewModes[x.mode.rawValue])
        interval = BehaviorRelay(value: x.interval)
        shuffled = BehaviorRelay(value: x.shuffled)
        groupCount = BehaviorRelay(value: x.groupCount)
        groupSelected = BehaviorRelay(value: x.groupSelected)
        speakingEnabled = BehaviorRelay(value: x.speakingEnabled)
        reviewCount = BehaviorRelay(value: x.reviewCount)
        onRepeat = BehaviorRelay(value: x.onRepeat)
        moveForward = BehaviorRelay(value: x.moveForward)
    }

    func save(to x: MReviewOptions) {
        x.mode = ReviewMode(rawValue: mode)!
        x.interval = interval.value
        x.shuffled = shuffled.value
        x.groupCount = groupCount.value
        x.groupSelected = groupSelected.value
        x.speakingEnabled = speakingEnabled.value
        x.reviewCount = reviewCount.value
        x.onRepeat = onRepeat.value
        x.moveForward = moveForward.value
    }
}
