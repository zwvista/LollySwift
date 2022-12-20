//
//  WordsSearchViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

class WordsSearchViewModel: WordsBaseViewModel {
    var arrWords = [MUnitWord]()

    func addNewWord() {
        let item = MUnitWord()
        item.WORD = newWord
        item.SEQNUM = arrWords.count + 1
        item.NOTE = ""
        arrWords.append(item)
        newWord = ""
    }
}
