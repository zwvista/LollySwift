//
//  SearchViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

class SearchViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var selectWord = ""

    public init(settings: SettingsViewModel, complete: @escaping () -> Void) {
        self.vmSettings = settings
        super.init()
    }
}
