//
//  SingleWordViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
import RxBinding

class SingleWordViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrWords_ = BehaviorRelay(value: [MUnitWord]())
    var arrWords: [MUnitWord] { get { arrWords_.value } set { arrWords_.accept(newValue) } }

    init(word: String, settings: SettingsViewModel) {
        vmSettings = settings
        super.init()
        MUnitWord.getDataByLangWord(langid: vmSettings.selectedLang.ID, word: word, arrTextbooks: vmSettings.arrTextbooks).map { [unowned self] in
            arrWords = $0
        }.subscribe() ~ rx.disposeBag
    }
}
