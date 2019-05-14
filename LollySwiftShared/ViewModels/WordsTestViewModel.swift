//
//  WordsTestViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsTestViewModel {

    var vmSettings: SettingsViewModel
    var mDictTranslation: MDictTranslation? {
        return vmSettings.selectedDictTranslation
    }
    
    init(settings: SettingsViewModel) {
        self.vmSettings = settings
    }

    var arrWords = [MUnitWord]()
    var arrCorrectIDs = [Int]()
    var index = 0
    
    func newTest(shuffled: Bool, levelge0only: Bool) -> Observable<()> {
        return MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrWords = $0
            self.arrCorrectIDs = []
            if levelge0only { self.arrWords = self.arrWords.filter { $0.LEVEL >= 0 } }
            if shuffled { self.arrWords = self.arrWords.shuffled() }
            self.index = 0
        }
    }

    func hasNext() -> Bool {
        return index < arrWords.count
    }
    func next() {
        index += 1
        if !hasNext() {
            index = 0
            arrWords = arrWords.filter { !arrCorrectIDs.contains($0.ID) }
        }
    }
    
    var currentWord: String {
        return hasNext() ? arrWords[index].WORD : ""
    }
    func getTranslation() -> Observable<String> {
        guard let mDictTranslation = mDictTranslation else { return Observable.empty() }
        let url = mDictTranslation.urlString(word: currentWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        return RestApi.getHtml(url: url).map { html in
            print(html)
            return CommonApi.extractText(from: html, transform: mDictTranslation.TRANSFORM!, template: "") { text,_ in text }
        }
    }
    
    func check(wordInput: String) -> Observable<()> {
        guard hasNext() else {return Observable.empty()}
        let o = arrWords[index]
        let isCorrect = o.WORD == wordInput
        if isCorrect { arrCorrectIDs.append(o.ID) }
        return MWordFami.update(wordid: o.WORDID, isCorrect: isCorrect).map {
            o.CORRECT = $0.CORRECT; o.TOTAL = $0.TOTAL
        }
    }
}
