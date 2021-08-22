//
//  SingleWordViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class SingleWordViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()

    init(word: String, settings: SettingsViewModel, complete: @escaping () -> ()) {
        vmSettings = settings
        super.init()
        MUnitWord.getDataByLangWord(langid: vmSettings.selectedLang.ID, word: word, arrTextbooks: vmSettings.arrTextbooks).map {
            self.arrWords = $0
        }.subscribe(onSuccess: {
            complete()
        }) ~ rx.disposeBag
    }
}
