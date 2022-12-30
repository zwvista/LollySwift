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
    var vmSettings: SettingsViewModel
    @Published var arrWords = [String]()
    @Published var currentWordIndex = 0
    var currentWord: String { arrWords[currentWordIndex] }
    func next(_ delta: Int) {
        currentWordIndex = (currentWordIndex + delta + arrWords.count) % arrWords.count
    }

    init(settings: SettingsViewModel, needCopy: Bool, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        super.init()
    }
}
