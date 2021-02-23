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
    let textFilter = BehaviorRelay(value: "")
    let indexTextbookFilter = BehaviorRelay(value: 0)
    var textbookFilter: Int {
        indexTextbookFilter.value == -1 ? 0 : vmSettings.arrTextbookFilters[indexTextbookFilter.value].value
    }

    init(settings: SettingsViewModel, needCopy: Bool) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
    }
}

class WordsBaseViewModel: WordsPhrasesBaseViewModel {
    let scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopeWordFilters[0])
    let newWord = BehaviorRelay(value: "")
    var selectedWord = ""
    var selectedWordID = 0
}
