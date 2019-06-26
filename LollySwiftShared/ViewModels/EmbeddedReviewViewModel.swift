//
//  EmbeddedReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class EmbeddedReviewViewModel: NSObject {
    var shuffled = true
    var levelge0only = true
    var subscription: Disposable? = nil
    var arrIDs = [Int]()
}
