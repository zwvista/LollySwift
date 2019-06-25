//
//  SingleWordViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class SingleWordViewModel {

    var vmSettings: SettingsViewModel
    let disposeBag: DisposeBag!
    var arrWords = [MUnitWord]()

    init(word: String, settings: SettingsViewModel, disposeBag: DisposeBag, complete: @escaping () -> ()) {
        vmSettings = settings
        self.disposeBag = disposeBag
        MUnitWord.getDataByLangWord(langid: vmSettings.selectedLang.ID, word: word, arrTextbooks: vmSettings.arrTextbooks).map {
            self.arrWords = $0
        }.subscribe {
            complete()
        }.disposed(by: disposeBag)
    }
}
