//
//  ReviewOptionsViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/07/18.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class ReviewOptionsViewModel: NSObject {
    var mode = 0
    @objc var interval = 3
    var shuffled = false
    var levelge0only: Bool?
    @objc var groupCount = 1
    @objc var groupSelected = 1
}
