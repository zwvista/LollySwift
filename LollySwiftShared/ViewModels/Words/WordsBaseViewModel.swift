//
//  WordsBaseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/05.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsPhrasesBaseViewModel: NSObject {
    var vmSettings: SettingsViewModel
    @objc dynamic var textFilter = ""
    let textbookFilter = BehaviorRelay(value: 0)

    init(settings: SettingsViewModel, needCopy: Bool) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
    }
}

class WordsBaseViewModel: WordsPhrasesBaseViewModel {
    let scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopeWordFilters[0])
    @objc dynamic var newWord = ""
    var selectedWord = ""
    var selectedWordID = 0
}
