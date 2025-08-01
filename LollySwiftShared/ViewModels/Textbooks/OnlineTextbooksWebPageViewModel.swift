//
//  OnlineTextbooksWebPageViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class OnlineTextbooksWebPageViewModel: NSObject, ObservableObject {

    @Published var arrOnlineTextbooks = [MOnlineTextbook]()
    @Published var selectedOnlineTextbookIndex = 0
    var selectedOnlineTextbook: MOnlineTextbook { arrOnlineTextbooks[selectedOnlineTextbookIndex] }
    func next(_ delta: Int) {
        selectedOnlineTextbookIndex = (selectedOnlineTextbookIndex + delta + arrOnlineTextbooks.count) % arrOnlineTextbooks.count
    }

    init(arrOnlineTextbooks: [MOnlineTextbook], selectedOnlineTextbookIndex: Int) {
        self.arrOnlineTextbooks = arrOnlineTextbooks
        self.selectedOnlineTextbookIndex = selectedOnlineTextbookIndex
        super.init()
    }
}
