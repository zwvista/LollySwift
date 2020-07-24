//
//  EmbeddedReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

class EmbeddedReviewViewModel: NSObject {
    var shuffled = false
    var levelge0only = true
    var subscription: Disposable? = nil

    func stop() {
        subscription?.dispose()
        subscription = nil
    }
    
    func start(arrIDs: [Int], interval: Double, getOne: @escaping (Int) -> ()) {
        var i = 0
        let wordCount = arrIDs.count
        subscription = Observable<Int>.interval(interval, scheduler: MainScheduler.instance).subscribe { _ in
            if i < wordCount {
                getOne(i)
                i += 1
            } else {
                self.stop()
            }
        }
        subscription?.disposed(by: rx.disposeBag)
    }
}
