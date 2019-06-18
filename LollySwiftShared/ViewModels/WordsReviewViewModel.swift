//
//  WordsReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsReviewViewModel {

    var vmSettings: SettingsViewModel
    
    init(settings: SettingsViewModel) {
        self.vmSettings = SettingsViewModel(settings)
    }

    var arrWords = [MUnitWord]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var mode: ReviewMode = .reviewAuto
    var isTestMode: Bool {
        return mode == .test
    }
    
    func newTest(shuffled: Bool, levelge0only: Bool) -> Observable<()> {
        return MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrWords = $0
            self.arrCorrectIDs = []
            if levelge0only { self.arrWords = self.arrWords.filter { $0.LEVEL >= 0 } }
            if shuffled { self.arrWords = self.arrWords.shuffled() }
            self.index = 0
        }
    }

    var hasNext: Bool {
        return index < arrWords.count
    }
    func next() {
        index += 1
        if isTestMode && !hasNext {
            index = 0
            arrWords = arrWords.filter { !arrCorrectIDs.contains($0.ID) }
        }
    }
    
    var currentItem: MUnitWord? {
        return hasNext ? arrWords[index] : nil
    }
    var currentWord: String {
        return hasNext ? arrWords[index].WORD : ""
    }
    func getTranslation() -> Observable<String> {
        guard vmSettings.hasDictTranslation else { return Observable.empty() }
        let mDictTranslation = vmSettings.selectedDictTranslation
        let url = mDictTranslation.urlString(word: currentWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        return RestApi.getHtml(url: url).map { html in
            print(html)
            return CommonApi.extractText(from: html, transform: mDictTranslation.TRANSFORM!, template: "") { text,_ in text }
        }
    }
    
    func check(wordInput: String) -> Observable<()> {
        guard hasNext else {return Observable.empty()}
        let o = currentItem!
        let isCorrect = o.WORD == wordInput
        if isCorrect { arrCorrectIDs.append(o.ID) }
        return MWordFami.update(wordid: o.WORDID, isCorrect: isCorrect).map {
            o.CORRECT = $0.CORRECT
            o.TOTAL = $0.TOTAL
        }
    }
}
