//
//  WordsDictViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsDictViewModel: NSObject {
    var vmSettings: SettingsViewModel
    var arrWords = [String]()
    var currentWordIndex_ = BehaviorRelay(value: 0)
    var currentWordIndex: Int { get { currentWordIndex_.value } set { currentWordIndex_.accept(newValue) } }
    var currentWord: String { arrWords[currentWordIndex] }
    func next(_ delta: Int) {
        currentWordIndex = (currentWordIndex + delta + arrWords.count) % arrWords.count
    }

    init(settings: SettingsViewModel, needCopy: Bool, arrWords: [String], currentWordIndex: Int, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.arrWords = arrWords
        super.init()
        self.currentWordIndex = currentWordIndex
    }
}
