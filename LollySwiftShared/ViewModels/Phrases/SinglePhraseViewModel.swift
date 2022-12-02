//
//  SinglePhraseViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxBinding

class SinglePhraseViewModel: NSObject {
    
    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    
    init(phrase: String, settings: SettingsViewModel, complete: @escaping () -> Void) {
        vmSettings = settings
        super.init()
        MUnitPhrase.getDataByLangPhrase(langid: vmSettings.selectedLang.ID, phrase: phrase, arrTextbooks: vmSettings.arrTextbooks).map {
            self.arrPhrases = $0
        }.subscribe(onSuccess: {
            complete()
        }) ~ rx.disposeBag
    }
}
