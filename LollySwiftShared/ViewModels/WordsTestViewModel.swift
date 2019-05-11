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
    var index = 0
    
    func newTest(shuffled: Bool, levelge0only: Bool) -> Observable<()> {
        return MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrWords = $0
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
}
