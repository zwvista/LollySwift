//
//  WordsDictViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class WordsDictViewModel: NSObject, ObservableObject {

    @Published var arrWords = [String]()
    @Published var selectedWordIndex = 0
    var selectedWord: String { arrWords[selectedWordIndex] }
    func next(_ delta: Int) {
        selectedWordIndex = (selectedWordIndex + delta + arrWords.count) % arrWords.count
    }

    init(arrWords: [String], selectedWordIndex: Int) {
        self.arrWords = arrWords
        self.selectedWordIndex = selectedWordIndex
        super.init()
    }
}
