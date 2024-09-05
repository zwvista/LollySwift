//
//  PatternsWebPageViewModel.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2018/04/14.
//  Copyright © 2018年 趙 偉. All rights reserved.
//

import Foundation

@MainActor
class PatternsWebPageViewModel: NSObject, ObservableObject {
    var vmSettings: SettingsViewModel
    @Published var arrPatterns = [MPattern]()
    @Published var currentPatternIndex = 0
    var currentPattern: MPattern { arrPatterns[currentPatternIndex] }
    func next(_ delta: Int) {
        currentPatternIndex = (currentPatternIndex + delta + arrPatterns.count) % arrPatterns.count
    }

    init(settings: SettingsViewModel, needCopy: Bool, arrPatterns: [MPattern], currentPatternIndex: Int, complete: @escaping () -> Void) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.arrPatterns = arrPatterns
        self.currentPatternIndex = currentPatternIndex
        super.init()
    }
}
