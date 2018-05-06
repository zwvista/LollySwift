//
//  SearchViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [String]()
    var selectWordIndex = 0
    var selectWord: String {
        return arrWords[selectWordIndex]
    }

    public init(settings: SettingsViewModel, complete: @escaping () -> ()) {
        self.vmSettings = settings
        super.init()
    }
}
