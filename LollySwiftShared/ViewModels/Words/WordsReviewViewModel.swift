//
//  WordsReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class WordsReviewViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var mode: ReviewMode = .reviewAuto
    var isTestMode: Bool { mode == .test }
    var subscription: Disposable? = nil
    var isSpeaking = true
    let options = MReviewOptions()

    @objc dynamic var indexString = ""
    @objc dynamic var indexHidden = false
    @objc dynamic var correctHidden = false
    @objc dynamic var incorrectHidden = false
    @objc dynamic var accuracyString = ""
    @objc dynamic var accuracyHidden = false
    @objc dynamic var checkEnabled = false
    @objc dynamic var wordTargetString = ""
    @objc dynamic var noteTargetString = ""
    @objc dynamic var wordTargetHidden = false
    @objc dynamic var noteTargetHidden = false
    @objc dynamic var translationString = ""
    @objc dynamic var wordInputString = ""
    @objc dynamic var checkTitle = ""

    init(settings: SettingsViewModel, needCopy: Bool) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
    }

    func newTest(options: MReviewOptions) -> Observable<()> {
        MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).map {
            self.arrWords = $0
            let count = self.arrWords.count
            let (from, to) = (count * (options.groupSelected - 1) / options.groupCount, count * options.groupSelected / options.groupCount)
            self.arrWords = [MUnitWord](self.arrWords[from..<to])
            self.arrCorrectIDs = []
            if options.levelge0only! { self.arrWords = self.arrWords.filter { $0.LEVEL >= 0 } }
            if options.shuffled { self.arrWords = self.arrWords.shuffled() }
            self.index = 0
        }
    }

    var hasNext: Bool { index < arrWords.count }
    func next() {
        index += 1
        if isTestMode && !hasNext {
            index = 0
            arrWords = arrWords.filter { !arrCorrectIDs.contains($0.ID) }
        }
    }
    
    var currentItem: MUnitWord? { hasNext ? arrWords[index] : nil }
    var currentWord: String { hasNext ? arrWords[index].WORD : "" }
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
    
    func doTest() {
        indexHidden = !hasNext
        correctHidden = true
        incorrectHidden = true
        accuracyHidden = !isTestMode || !hasNext
        checkEnabled = hasNext
        wordTargetString = currentWord
        noteTargetString = currentItem?.NOTE ?? ""
        wordTargetHidden = isTestMode
        noteTargetHidden = isTestMode
        translationString = ""
        wordInputString = ""
        if hasNext {
            indexString = "\(index + 1)/\(arrWords.count)"
            accuracyString = currentItem!.ACCURACY
            getTranslation().subscribe(onNext: {
                self.translationString = $0
            }) ~ rx.disposeBag
        }
    }
}
