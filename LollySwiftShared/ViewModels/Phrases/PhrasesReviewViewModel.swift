//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesReviewViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var mode: ReviewMode = .reviewAuto
    var isTestMode: Bool { mode == .test }

    init(settings: SettingsViewModel, needCopy: Bool) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
    }

    func newTest(options: MReviewOptions) -> Observable<()> {
        MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrPhrases = $0
            let count = self.arrPhrases.count
            let (from, to) = (count * (options.groupSelected - 1) / options.groupCount, count * options.groupSelected / options.groupCount)
            self.arrPhrases = [MUnitPhrase](self.arrPhrases[from..<to])
            self.arrCorrectIDs = []
            if options.shuffled { self.arrPhrases = self.arrPhrases.shuffled() }
            self.index = 0
        }
    }

    var hasNext: Bool { index < arrPhrases.count }
    func next() {
        index += 1
        if isTestMode && !hasNext {
            index = 0
            arrPhrases = arrPhrases.filter { !arrCorrectIDs.contains($0.ID) }
        }
    }
    
    var currentItem: MUnitPhrase? { hasNext ? arrPhrases[index] : nil }
    var currentPhrase: String { hasNext ? arrPhrases[index].PHRASE : "" }
    
    func check(phraseInput: String) {
        guard hasNext else {return}
        let o = arrPhrases[index]
        let isCorrect = o.PHRASE == phraseInput
        if isCorrect { arrCorrectIDs.append(o.ID) }
    }
}
