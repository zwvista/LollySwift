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
import RxBinding

class WordsPhrasesBaseViewModel: NSObject {
    var vmSettings: SettingsViewModel
    let textFilter = BehaviorRelay(value: "")
    let indexTextbookFilter = BehaviorRelay(value: 0)
    let stringTextbookFilter = BehaviorRelay(value: "")
    var textbookFilter: Int {
        indexTextbookFilter.value == -1 ? 0 : vmSettings.arrTextbookFilters[indexTextbookFilter.value].value
    }

    init(settings: SettingsViewModel, needCopy: Bool) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        stringTextbookFilter.accept(vmSettings.arrTextbookFilters[0].label)
        stringTextbookFilter.subscribe(onNext: { s in
            self.indexTextbookFilter.accept(self.vmSettings.arrTextbookFilters.firstIndex { $0.label == s }!)
        }) ~ rx.disposeBag
    }
}

class WordsBaseViewModel: WordsPhrasesBaseViewModel {
    let scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopeWordFilters[0])
    let newWord = BehaviorRelay(value: "")
    var selectedWord = ""
    var selectedWordID = 0
}
