//
//  MReviewOptions.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

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

class MReviewOptionsEdit: ObservableObject {
    @Published var mode: Int
    @Published var modeString: String
    @Published var interval: Int
    @Published var shuffled: Bool
    @Published var groupCount: Int
    @Published var groupSelected: Int
    @Published var speakingEnabled: Bool
    @Published var reviewCount: Int
    @Published var onRepeat: Bool
    @Published var moveForward: Bool

    init(x: MReviewOptions) {
        mode = x.mode.rawValue
        modeString = SettingsViewModel.reviewModes[x.mode.rawValue]
        interval = x.interval
        shuffled = x.shuffled
        groupCount = x.groupCount
        groupSelected = x.groupSelected
        speakingEnabled = x.speakingEnabled
        reviewCount = x.reviewCount
        onRepeat = x.onRepeat
        moveForward = x.moveForward
    }

    func save(to x: MReviewOptions) {
        x.mode = ReviewMode(rawValue: mode)!
        x.interval = interval
        x.shuffled = shuffled
        x.groupCount = groupCount
        x.groupSelected = groupSelected
        x.speakingEnabled = speakingEnabled
        x.reviewCount = reviewCount
        x.onRepeat = onRepeat
        x.moveForward = moveForward
    }
}
