//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesReviewViewModel {

    var vmSettings: SettingsViewModel
    
    init(settings: SettingsViewModel) {
        self.vmSettings = settings
    }

    var arrPhrases = [MUnitPhrase]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var mode: ReviewMode = .reviewAuto
    var isTestMode: Bool {
        return mode == .test
    }
    
    func newTest(mode: ReviewMode, shuffled: Bool) -> Observable<()> {
        self.mode = mode
        return MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrPhrases = $0
            self.arrCorrectIDs = []
            if shuffled { self.arrPhrases = self.arrPhrases.shuffled() }
            self.index = 0
        }
    }

    func hasNext() -> Bool {
        return index < arrPhrases.count
    }
    func next() {
        index += 1
        if isTestMode && !hasNext() {
            index = 0
            arrPhrases = arrPhrases.filter { !arrCorrectIDs.contains($0.ID) }
        }
    }
    
    var currentPhrase: String {
        return hasNext() ? arrPhrases[index].PHRASE : ""
    }
    
    func check(phraseInput: String) {
        guard hasNext() else {return}
        let o = arrPhrases[index]
        let isCorrect = o.PHRASE == phraseInput
        if isCorrect { arrCorrectIDs.append(o.ID) }
    }
}
