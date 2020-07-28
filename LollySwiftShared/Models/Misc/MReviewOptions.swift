//
//  MReviewOptions.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

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
