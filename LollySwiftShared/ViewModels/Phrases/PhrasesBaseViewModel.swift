//
//  PhrasesBaseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/05.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesBaseViewModel: WordsPhrasesBaseViewModel {
    var scopeFilter = BehaviorRelay(value: SettingsViewModel.arrScopePhraseFilters[0])
    var selectedPhrase = ""
    var selectedPhraseID = 0
}
