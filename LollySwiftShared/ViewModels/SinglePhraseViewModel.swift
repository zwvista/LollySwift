//
//  SinglePhraseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class SinglePhraseViewModel {
    
    var vmSettings: SettingsViewModel
    let disposeBag: DisposeBag!
    var arrPhrases = [MUnitPhrase]()
    
    init(phrase: String, settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        vmSettings = settings
        self.disposeBag = disposeBag
        MUnitPhrase.getDataByLangPhrase(langid: vmSettings.selectedLang.ID, phrase: phrase, arrTextbooks: vmSettings.arrTextbooks).map {
            self.arrPhrases = $0
        }.subscribe {
            complete()
        }.disposed(by: disposeBag)
    }
}
