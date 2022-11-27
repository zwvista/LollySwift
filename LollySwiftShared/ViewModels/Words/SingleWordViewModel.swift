//
//  SingleWordViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class SingleWordViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()

    init(word: String, settings: SettingsViewModel, complete: @escaping () -> ()) {
        vmSettings = settings
        super.init()
        Task {
            arrWords = await MUnitWord.getDataByLangWord(langid: vmSettings.selectedLang.ID, word: word, arrTextbooks: vmSettings.arrTextbooks)
            complete()
        }
    }
}
