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
    var selectedWordIndex_ = BehaviorRelay(value: 0)
    var selectedWordIndex: Int { get { selectedWordIndex_.value } set { selectedWordIndex_.accept(newValue) } }
    var selectedWord: String { arrWords[selectedWordIndex] }
    func next(_ delta: Int) {
        selectedWordIndex = (selectedWordIndex + delta + arrWords.count) % arrWords.count
    }

    init(settings: SettingsViewModel, arrWords: [String], selectedWordIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrWords = arrWords
        super.init()
        self.selectedWordIndex = selectedWordIndex
    }
}
