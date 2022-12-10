//
//  WordsBaseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/05.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Foundation
import Combine

@MainActor
class WordsPhrasesBaseViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var textFilter = ""
    @Published var indexTextbookFilter = 0
    @Published var stringTextbookFilter = ""
    var textbookFilter: Int {
        indexTextbookFilter == -1 ? 0 : vmSettings.arrTextbookFilters[indexTextbookFilter].value
    }

    var subscriptions = Set<AnyCancellable>()

    init(settings: SettingsViewModel, needCopy: Bool) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
        stringTextbookFilter = vmSettings.arrTextbookFilters[0].label
        $stringTextbookFilter.sink { s in
            self.indexTextbookFilter = self.vmSettings.arrTextbookFilters.firstIndex { $0.label == s }!
        } ~ subscriptions
    }
}

class WordsBaseViewModel: WordsPhrasesBaseViewModel {
    @Published var scopeFilter = SettingsViewModel.arrScopeWordFilters[0]
    @Published var newWord = ""
    var selectedWord = ""
    var selectedWordID = 0
}
