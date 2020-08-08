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
    var options = MReviewOptions(isEmbedded: true)
    var subscription: Disposable? = nil

    func stop() {
        subscription?.dispose()
        subscription = nil
    }
    
    func start(arrIDs: [Int], interval: Int, getOne: @escaping (Int) -> ()) {
        var i = 0
        let wordCount = arrIDs.count
        subscription = Observable<Int>.interval(DispatchTimeInterval.seconds(interval), scheduler: MainScheduler.instance).subscribe { _ in
            if i < wordCount {
                getOne(i)
                i += 1
            } else {
                self.stop()
            }
        }
        subscription! ~ rx.disposeBag
    }
}
