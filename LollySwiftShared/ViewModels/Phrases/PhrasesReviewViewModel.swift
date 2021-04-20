//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class PhrasesReviewViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrCorrectIDs = [Int]()
    var index = 0
    let options = MReviewOptions()
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var subscriptionTimer: Disposable? = nil
    let doTestAction: (() -> Void)?

    let indexString = BehaviorRelay(value: "")
    let indexHidden = BehaviorRelay(value: false)
    let correctHidden = BehaviorRelay(value: true)
    let incorrectHidden = BehaviorRelay(value: true)
    let checkEnabled = BehaviorRelay(value: false)
    let phraseTargetString = BehaviorRelay(value: "")
    let phraseTargetHidden = BehaviorRelay(value: false)
    let translationString = BehaviorRelay(value: "")
    let phraseInputString = BehaviorRelay(value: "")
    let checkTitle = BehaviorRelay(value: "Check")
    let isSpeaking = BehaviorRelay(value: true)

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
        subscriptionTimer?.dispose()
        if options.mode == .textbook {
            MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook).subscribe(onNext: { arr in
                let cnt = min(self.options.reviewCount, arr.count)
                self.arrPhrases = Array(arr.shuffled()[0..<cnt])
                f()
            }) ~ self.rx.disposeBag
        } else {
            MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: {
                self.arrPhrases = $0
                let count = self.arrPhrases.count
                let from = count * (self.options.groupSelected - 1) / self.options.groupCount
                let to = count * self.options.groupSelected / self.options.groupCount
                self.arrPhrases = [MUnitPhrase](self.arrPhrases[from..<to])
                if self.options.shuffled { self.arrPhrases = self.arrPhrases.shuffled() }
                f()
                if self.options.mode == .reviewAuto {
                    self.subscriptionTimer = Observable<Int>.interval(.seconds(self.options.interval), scheduler: MainScheduler.instance).subscribe { _ in
                        self.check()
                    }
                    self.subscriptionTimer?.disposed(by: self.rx.disposeBag)
                }
            }) ~ self.rx.disposeBag
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
    
    func check() {
        if !isTestMode {
            var b = true
            if options.mode == .reviewManual && !phraseInputString.value.isEmpty && phraseInputString.value != currentPhrase {
                b = false
                incorrectHidden.accept(false)
            }
            if b {
                next()
                doTest()
            }
        } else if correctHidden.value && incorrectHidden.value {
            phraseInputString.accept(vmSettings.autoCorrectInput(text: phraseInputString.value))
            phraseTargetHidden.accept(false)
            if phraseInputString.value == currentPhrase {
                correctHidden.accept(false)
            } else {
                incorrectHidden.accept(false)
            }
            checkTitle.accept("Next")
            guard hasNext else {return}
            let o = arrPhrases[index]
            let isCorrect = o.PHRASE == phraseInputString.value
            if isCorrect { arrCorrectIDs.append(o.ID) }
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
        checkEnabled.accept(hasNext)
        phraseTargetString.accept(currentPhrase)
        translationString.accept(currentItem?.TRANSLATION ?? "")
        phraseTargetHidden.accept(isTestMode)
        phraseInputString.accept("")
        doTestAction?()
        if hasNext {
            indexString.accept("\(index + 1)/\(arrPhrases.count)")
        } else {
            subscriptionTimer?.dispose()
        }
    }
}
