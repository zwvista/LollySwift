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

    var arrOnlineTextbooks = [MOnlineTextbook]()
    var selectedOnlineTextbookIndex_ = BehaviorRelay(value: 0)
    var selectedOnlineTextbookIndex: Int { get { selectedOnlineTextbookIndex_.value } set { selectedOnlineTextbookIndex_.accept(newValue) } }
    var selectedOnlineTextbook: MOnlineTextbook { arrOnlineTextbooks[selectedOnlineTextbookIndex] }
    func next(_ delta: Int) {
        selectedOnlineTextbookIndex = (selectedOnlineTextbookIndex + delta + arrOnlineTextbooks.count) % arrOnlineTextbooks.count
    }

    init(arrOnlineTextbooks: [MOnlineTextbook], selectedOnlineTextbookIndex: Int) {
        self.arrOnlineTextbooks = arrOnlineTextbooks
        super.init()
        self.selectedOnlineTextbookIndex = selectedOnlineTextbookIndex
    }
}
