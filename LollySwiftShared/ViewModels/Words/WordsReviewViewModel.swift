//
//  WordsReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class WordsReviewViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrWords = [MUnitWord]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var subscription: Disposable? = nil
    let options = MReviewOptions()
    let doTestAction: (() -> Void)?

    var indexString = BehaviorRelay(value: "")
    var indexHidden = BehaviorRelay(value: false)
    var correctHidden = BehaviorRelay(value: true)
    var incorrectHidden = BehaviorRelay(value: true)
    var accuracyString = BehaviorRelay(value: "")
    var accuracyHidden = BehaviorRelay(value: false)
    var checkEnabled = BehaviorRelay(value: false)
    var wordTargetString = BehaviorRelay(value: "")
    var noteTargetString = BehaviorRelay(value: "")
    var wordHintString = BehaviorRelay(value: "")
    var wordTargetHidden = BehaviorRelay(value: false)
    var noteTargetHidden = BehaviorRelay(value: false)
    var wordHintHidden = BehaviorRelay(value: false)
    var translationString = BehaviorRelay(value: "")
    var wordInputString = BehaviorRelay(value: "")
    var checkTitle = BehaviorRelay(value: "Check")
    var isSpeaking = BehaviorRelay(value: true)
    var searchEnabled = BehaviorRelay(value: false)

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: (() -> Void)? = nil) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.doTestAction = doTestAction
        options.shuffled = true
    }

    func newTest() {
        func f() {
            self.arrCorrectIDs = []
            self.index = 0
            self.doTest()
            self.checkTitle.accept(self.isTestMode ? "Check" : "Next")
        }
        subscription?.dispose()
        if options.mode == .textbook {
            MUnitWord.getDataByTextbook(vmSettings.selectedTextbook).subscribe(onNext: { arr in
                var arr2 = [MUnitWord]()
                for o in arr {
                    let s = o.ACCURACY
                    let t = min(6, 11 - (s.last != "%" ? 0 : (s.replacingOccurrences(of: "%", with: "").toDouble()! / 10).toInt))
                    for _ in 0..<t {
                        arr2.append(o)
                    }
                }
                self.arrWords = []
                let cnt = min(self.options.reviewCount, arr.count)
                while self.arrWords.count < cnt {
                    let o = arr2.random()!
                    if !self.arrWords.contains(where: { $0.ID == o.ID }) {
                        self.arrWords.append(o)
                    }
                }
                f()
            }) ~ self.rx.disposeBag
        } else {
            MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: {
                self.arrWords = $0
                let count = self.arrWords.count
                let from = count * (self.options.groupSelected - 1) / self.options.groupCount
                let to = count * self.options.groupSelected / self.options.groupCount
                self.arrWords = [MUnitWord](self.arrWords[from..<to])
                if self.options.shuffled { self.arrWords = self.arrWords.shuffled() }
                f()
                if self.options.mode == .reviewAuto {
                    self.subscription = Observable<Int>.interval(DispatchTimeInterval.seconds( self.options.interval), scheduler: MainScheduler.instance).subscribe { _ in
                        self.check()
                    }
                    self.subscription?.disposed(by: self.rx.disposeBag)
                }
            }) ~ self.rx.disposeBag
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
    
    func check() {
        if !isTestMode {
            var b = true
            if options.mode == .reviewManual && !wordInputString.value.isEmpty && wordInputString.value != currentWord {
                b = false
                incorrectHidden.accept(false)
            }
            if b {
                next()
                doTest()
            }
        } else if correctHidden.value && incorrectHidden.value {
            wordInputString.accept(vmSettings.autoCorrectInput(text: wordInputString.value))
            wordTargetHidden.accept(false)
            noteTargetHidden.accept(false)
            if wordInputString.value == currentWord {
                correctHidden.accept(false)
            } else {
                incorrectHidden.accept(false)
            }
            wordHintHidden.accept(true)
            searchEnabled.accept(true)
            checkTitle.accept("Next")
            guard hasNext else {return}
            let o = currentItem!
            let isCorrect = o.WORD == wordInputString.value
            if isCorrect { arrCorrectIDs.append(o.ID) }
            MWordFami.update(wordid: o.WORDID, isCorrect: isCorrect).map {
                o.CORRECT = $0.CORRECT
                o.TOTAL = $0.TOTAL
            }.subscribe() ~ rx.disposeBag
        } else {
            next()
            doTest()
            checkTitle.accept("Check")
        }
    }
    
    func doTest() {
        indexHidden.accept(!hasNext)
        correctHidden.accept(true)
        incorrectHidden.accept(true)
        accuracyHidden.accept(!isTestMode || !hasNext)
        checkEnabled.accept(hasNext)
        wordTargetString.accept(currentWord)
        noteTargetString.accept(currentItem?.NOTE ?? "")
        wordHintString.accept(currentItem?.WORD.length.toString ?? "")
        wordTargetHidden.accept(isTestMode)
        noteTargetHidden.accept(isTestMode)
        wordHintHidden.accept(!isTestMode)
        translationString.accept("")
        wordInputString.accept("")
        searchEnabled.accept(false)
        doTestAction?()
        if hasNext {
            indexString.accept("\(index + 1)/\(arrWords.count)")
            accuracyString.accept(currentItem!.ACCURACY)
            getTranslation().subscribe(onNext: {
                self.translationString.accept($0)
            }) ~ rx.disposeBag
        } else {
            subscription?.dispose()
        }
    }
}
