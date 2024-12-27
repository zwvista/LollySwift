//
//  OnlineTextbooksWebPageViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class OnlineTextbooksWebPageViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrOnlineTextbooks = [MOnlineTextbook]()
    var currentOnlineTextbookIndex_ = BehaviorRelay(value: 0)
    var currentOnlineTextbookIndex: Int { get { currentOnlineTextbookIndex_.value } set { currentOnlineTextbookIndex_.accept(newValue) } }
    var currentOnlineTextbook: MOnlineTextbook { arrOnlineTextbooks[currentOnlineTextbookIndex] }
    func next(_ delta: Int) {
        currentOnlineTextbookIndex = (currentOnlineTextbookIndex + delta + arrOnlineTextbooks.count) % arrOnlineTextbooks.count
    }

    init(settings: SettingsViewModel, arrOnlineTextbooks: [MOnlineTextbook], currentOnlineTextbookIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrOnlineTextbooks = arrOnlineTextbooks
        super.init()
        self.currentOnlineTextbookIndex = currentOnlineTextbookIndex
    }
}
