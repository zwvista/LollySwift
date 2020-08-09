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
    var isEmbedded = false
    var mode: ReviewMode = .reviewAuto
    @objc dynamic var interval = 3
    var shuffled = false
    var levelge0only: Bool?
    @objc dynamic var groupCount = 1
    @objc dynamic var groupSelected = 1
    
    init(isEmbedded: Bool = false) {
        self.isEmbedded = isEmbedded
        super.init()
    }
    
    func copy(from x: MReviewOptions) {
        isEmbedded = x.isEmbedded
        mode = x.mode
        interval = x.interval
        shuffled = x.shuffled
        levelge0only = x.levelge0only
        groupCount = x.groupCount
        groupSelected = x.groupSelected
    }
}

class MReviewOptionsEdit {
    var mode: BehaviorRelay<Int>
    var interval: BehaviorRelay<Int>
    var shuffled: BehaviorRelay<Bool>
    var levelge0only: BehaviorRelay<Bool>
    var levelHidden: BehaviorRelay<Bool>
    var groupCount: BehaviorRelay<Int>
    var groupSelected: BehaviorRelay<Int>
    
    init(x: MReviewOptions) {
        mode = BehaviorRelay(value: x.mode.rawValue)
        interval = BehaviorRelay(value: x.interval)
        shuffled = BehaviorRelay(value: x.shuffled)
        levelge0only = BehaviorRelay(value: x.levelge0only ?? false)
        levelHidden = BehaviorRelay(value: x.levelge0only == nil)
        groupCount = BehaviorRelay(value: x.groupCount)
        groupSelected = BehaviorRelay(value: x.groupSelected)
    }
    
    func save(to x: MReviewOptions) {
        x.mode = ReviewMode(rawValue: mode.value)!
        x.interval = interval.value
        x.shuffled = shuffled.value
        if (x.levelge0only != nil) {
            x.levelge0only = levelge0only.value
        }
        x.groupCount = groupCount.value
        x.groupSelected = groupSelected.value
    }
}
