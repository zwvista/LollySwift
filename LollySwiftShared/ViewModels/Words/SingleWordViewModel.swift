//
//  SingleWordViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/25.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

@MainActor
class SingleWordViewModel: NSObject {

    @Published var arrWords = [MUnitWord]()

    init(word: String) {
        super.init()
        Task {
            arrWords = await MUnitWord.getDataByLangWord(langid: vmSettings.selectedLang.ID, word: word, arrTextbooks: vmSettings.arrTextbooks)
        }
    }
}
