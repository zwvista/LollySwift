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
    var count: Int { arrPhrases.count }
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
    let checkNextEnabled = BehaviorRelay(value: false)
    let checkNextTitle = BehaviorRelay(value: "Check")
    let checkPrevEnabled = BehaviorRelay(value: false)
    let checkPrevTitle = BehaviorRelay(value: "Check")
    let phraseTargetString = BehaviorRelay(value: "")
    let phraseTargetHidden = BehaviorRelay(value: false)
    let translationString = BehaviorRelay(value: "")
    let phraseInputString = BehaviorRelay(value: "")
    let isSpeaking = BehaviorRelay(value: true)
    let moveForward = BehaviorRelay(value: true)
    let onRepeat = BehaviorRelay(value: true)
    let moveForwardHidden = BehaviorRelay(value: false)
    let onRepeatHidden = BehaviorRelay(value: false)

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: (() -> Void)? = nil) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.doTestAction = doTestAction
        options.shuffled = true
    }

    func newTest() {
        func f() {
            index = options.moveForward ? 0 : count - 1
            doTest()
            checkNextTitle.accept(isTestMode ? "Check" : "Next")
            checkPrevTitle.accept(isTestMode ? "Check" : "Prev")
        }
        index = 0
        arrPhrases.removeAll()
        arrCorrectIDs.removeAll()
        subscriptionTimer?.dispose()
        isSpeaking.accept(options.speakingEnabled)
        moveForward.accept(options.moveForward)
        onRepeat.accept(options.onRepeat)
        if options.mode == .textbook {
            MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook).subscribe(onNext: { arr in
                let cnt = min(self.options.reviewCount, arr.count)
                self.arrPhrases = Array(arr.shuffled()[0..<cnt])
                f()
            }) ~ self.rx.disposeBag
        } else {
            MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: {
                self.arrPhrases = $0
                let count = self.count
                let from = count * (self.options.groupSelected - 1) / self.options.groupCount
                let to = count * self.options.groupSelected / self.options.groupCount
                self.arrPhrases = [MUnitPhrase](self.arrPhrases[from..<to])
                if self.options.shuffled { self.arrPhrases = self.arrPhrases.shuffled() }
                f()
                if self.options.mode == .reviewAuto {
                    self.subscriptionTimer = Observable<Int>.interval(.seconds(self.options.interval), scheduler: MainScheduler.instance).subscribe { _ in
                        self.check(toNext: true)
                    }
                    self.subscriptionTimer?.disposed(by: self.rx.disposeBag)
                }
            }) ~ self.rx.disposeBag
        }
    }

    var hasCurrent: Bool { !arrPhrases.isEmpty && (onRepeat.value || 0..<count ~= index) }
    func move(toNext: Bool) {
        func checkOnRepeat() {
            if onRepeat.value {
                index = (index + count) % count
            }
        }
        if moveForward.value == toNext {
            index += 1
            checkOnRepeat()
            if isTestMode && !hasCurrent {
                index = 0
                arrPhrases = arrPhrases.filter { !arrCorrectIDs.contains($0.ID) }
            }
        } else {
            index -= 1
            checkOnRepeat()
        }
    }
    
    var currentItem: MUnitPhrase? { hasCurrent ? arrPhrases[index] : nil }
    var currentPhrase: String { hasCurrent ? arrPhrases[index].PHRASE : "" }
    
    func check(toNext: Bool) {
        if !isTestMode {
            var b = true
            if options.mode == .reviewManual && !phraseInputString.value.isEmpty && phraseInputString.value != currentPhrase {
                b = false
                incorrectHidden.accept(false)
            }
            if b {
                move(toNext: toNext)
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
            checkNextTitle.accept("Next")
            checkPrevTitle.accept("Prev")
            guard hasCurrent else {return}
            let o = arrPhrases[index]
            let isCorrect = o.PHRASE == phraseInputString.value
            if isCorrect { arrCorrectIDs.append(o.ID) }
        } else {
            move(toNext: toNext)
            doTest()
            checkNextTitle.accept("Check")
            checkPrevTitle.accept("Check")
        }
    }
    
    func doTest() {
        indexHidden.accept(!hasCurrent)
        correctHidden.accept(true)
        incorrectHidden.accept(true)
        checkNextEnabled.accept(hasCurrent)
        checkPrevEnabled.accept(hasCurrent)
        phraseTargetString.accept(currentPhrase)
        translationString.accept(currentItem?.TRANSLATION ?? "")
        phraseTargetHidden.accept(isTestMode)
        phraseInputString.accept("")
        doTestAction?()
        if hasCurrent {
            indexString.accept("\(index + 1)/\(count)")
        } else {
            subscriptionTimer?.dispose()
        }
    }
}
