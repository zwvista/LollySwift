//
//  MReviewOptions.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class MReviewOptions: NSObject {
    var mode = 0
    @objc dynamic var interval = 3
    var shuffled = false
    var levelge0only: Bool?
    @objc dynamic var groupCount = 1
    @objc dynamic var groupSelected = 1
}
