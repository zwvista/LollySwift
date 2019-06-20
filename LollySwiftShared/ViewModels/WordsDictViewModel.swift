//
//  WordsDictViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsDictViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [String]()
    var selectedWordIndex = 0
    var selectedWord: String {
        return arrWords[selectedWordIndex]
    }

    public init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> ()) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
    }
}
