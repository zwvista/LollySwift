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
    var vmSettings: SettingsViewModel
    @Published var arrOnlineTextbooks = [MOnlineTextbook]()
    @Published var currentOnlineTextbookIndex = 0
    var currentOnlineTextbook: MOnlineTextbook { arrOnlineTextbooks[currentOnlineTextbookIndex] }
    func next(_ delta: Int) {
        currentOnlineTextbookIndex = (currentOnlineTextbookIndex + delta + arrOnlineTextbooks.count) % arrOnlineTextbooks.count
    }

    init(settings: SettingsViewModel, arrOnlineTextbooks: [MOnlineTextbook], currentOnlineTextbookIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrOnlineTextbooks = arrOnlineTextbooks
        self.currentOnlineTextbookIndex = currentOnlineTextbookIndex
        super.init()
    }
}
