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
    @Published var selectedPatternIndex = 0
    var selectedPattern: MPattern { arrPatterns[selectedPatternIndex] }
    func next(_ delta: Int) {
        selectedPatternIndex = (selectedPatternIndex + delta + arrPatterns.count) % arrPatterns.count
    }

    init(settings: SettingsViewModel, arrPatterns: [MPattern], selectedPatternIndex: Int, complete: @escaping () -> Void) {
        vmSettings = settings
        self.arrPatterns = arrPatterns
        self.selectedPatternIndex = selectedPatternIndex
        super.init()
    }
}
