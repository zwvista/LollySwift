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
    let textFilter_ = BehaviorRelay(value: "")
    var textFilter: String { get { textFilter_.value } set { textFilter_.accept(newValue) } }
    let indexTextbookFilter_ = BehaviorRelay(value: 0)
    var indexTextbookFilter: Int { get { indexTextbookFilter_.value } set { indexTextbookFilter_.accept(newValue) } }
    let stringTextbookFilter_ = BehaviorRelay(value: "")
    var stringTextbookFilter: String { get { stringTextbookFilter_.value } set { stringTextbookFilter_.accept(newValue) } }
    var textbookFilter: Int {
        indexTextbookFilter == -1 ? 0 : vmSettings.arrTextbookFilters[indexTextbookFilter].value
    }

    init(settings: SettingsViewModel, needCopy: Bool) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        stringTextbookFilter = vmSettings.arrTextbookFilters[0].label
        stringTextbookFilter_.subscribe { [unowned self] s in
            indexTextbookFilter = vmSettings.arrTextbookFilters.firstIndex { $0.label == s }!
        } ~ rx.disposeBag
    }
}

class WordsBaseViewModel: WordsPhrasesBaseViewModel {
    let scopeFilter_ = BehaviorRelay(value: SettingsViewModel.arrScopeWordFilters[0])
    var scopeFilter: String { get { scopeFilter_.value } set { scopeFilter_.accept(newValue) } }
    let newWord_ = BehaviorRelay(value: "")
    var newWord: String { get { newWord_.value } set { newWord_.accept(newValue) } }
    var selectedWord = ""
    var selectedWordID = 0
}
