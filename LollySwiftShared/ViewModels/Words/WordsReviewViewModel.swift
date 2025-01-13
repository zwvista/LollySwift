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
import RxBinding

class WordsReviewViewModel: WordsBaseViewModel {

    var arrWords = [MUnitWord]()
    var count: Int { arrWords.count }
    var arrCorrectIDs = [Int]()
    var index = 0
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var needSearchDict: Bool { options.mode == .reviewAuto || options.mode == .reviewManual }
    var subscriptionTimer: Disposable? = nil
    let options = MReviewOptions()
    let doTestAction: ((WordsReviewViewModel) -> Void)?

    let indexString = BehaviorRelay(value: "")
    let indexHidden = BehaviorRelay(value: false)
    let correctHidden = BehaviorRelay(value: true)
    let incorrectHidden = BehaviorRelay(value: true)
    let accuracyString = BehaviorRelay(value: "")
    let accuracyHidden = BehaviorRelay(value: false)
    let checkNextEnabled = BehaviorRelay(value: false)
    let checkNextTitle = BehaviorRelay(value: "Check")
    let checkPrevEnabled = BehaviorRelay(value: false)
    let checkPrevTitle = BehaviorRelay(value: "Check")
    let checkPrevHidden = BehaviorRelay(value: false)
    let wordTargetString = BehaviorRelay(value: "")
    let noteTargetString = BehaviorRelay(value: "")
    let wordHintString = BehaviorRelay(value: "")
    let wordTargetHidden = BehaviorRelay(value: false)
    let noteTargetHidden = BehaviorRelay(value: false)
    let wordHintHidden = BehaviorRelay(value: false)
    let translationString = BehaviorRelay(value: "")
    let wordInputString = BehaviorRelay(value: "")
    let isSpeaking = BehaviorRelay(value: true)
    let moveForward = BehaviorRelay(value: true)
    let onRepeat = BehaviorRelay(value: true)
    let moveForwardHidden = BehaviorRelay(value: false)
    let onRepeatHidden = BehaviorRelay(value: false)

    init(settings: SettingsViewModel, doTestAction: ((WordsReviewViewModel) -> Void)? = nil) {
        self.doTestAction = doTestAction
        super.init(settings: settings)
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
        arrWords.removeAll()
        arrCorrectIDs.removeAll()
        stopTimer()
        isSpeaking.accept(options.speakingEnabled)
        moveForward.accept(options.moveForward)
        moveForwardHidden.accept(isTestMode)
        onRepeat.accept(!isTestMode && options.onRepeat)
        onRepeatHidden.accept(isTestMode)
        checkPrevHidden.accept(isTestMode)
        if options.mode == .textbook {
            MUnitWord.getDataByTextbook(vmSettings.selectedTextbook).subscribe { [unowned self] arr in
                var arr2 = [MUnitWord]()
                for o in arr {
                    let s = o.ACCURACY
                    let percentage = s.last != "%" ? 0 : Double(s.replacingOccurrences(of: "%", with: ""))!
                    let t = 6 - Int(percentage / 20)
                    for _ in 0..<t {
                        arr2.append(o)
                    }
                }
                arrWords = []
                let cnt = min(options.reviewCount, arr.count)
                while count < cnt {
                    let o = arr2.randomElement()!
                    if !arrWords.contains(where: { $0.ID == o.ID }) {
                        arrWords.append(o)
                    }
                }
                f()
            } ~ rx.disposeBag
        } else {
            MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe { [unowned self] in
                arrWords = $0
                let count = count
                let from = count * (options.groupSelected - 1) / options.groupCount
                let to = count * options.groupSelected / options.groupCount
                arrWords = [MUnitWord](arrWords[from..<to])
                if options.shuffled { arrWords = arrWords.shuffled() }
                f()
                if options.mode == .reviewAuto {
                    subscriptionTimer = Observable<Int>.interval(.seconds( options.interval), scheduler: MainScheduler.instance).subscribe { [unowned self] _ in
                        check(toNext: true)
                    }
                    subscriptionTimer?.disposed(by: rx.disposeBag)
                }
            } ~ rx.disposeBag
        }
    }

    var hasCurrent: Bool { !arrWords.isEmpty && (onRepeat.value || 0..<count ~= index) }
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
                arrWords = arrWords.filter { !arrCorrectIDs.contains($0.ID) }
            }
        } else {
            index -= 1
            checkOnRepeat()
        }
    }

    var currentItem: MUnitWord? { hasCurrent ? arrWords[index] : nil }
    var currentWord: String { hasCurrent ? arrWords[index].WORD : "" }
    func getTranslation() -> Single<String> {
        guard vmSettings.hasDictTranslation else { return Single.just("") }
        let mDictTranslation = vmSettings.selectedDictTranslation
        let url = mDictTranslation.urlString(word: currentWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        return RestApi.getHtml(url: url).map { html in
//            print(html)
            return CommonApi.extractText(from: html, transform: mDictTranslation.TRANSFORM, template: "") { text,_ in text }
        }
    }

    func check(toNext: Bool) {
        if !isTestMode {
            var b = true
            if options.mode == .reviewManual && !wordInputString.value.isEmpty && wordInputString.value != currentWord {
                b = false
                incorrectHidden.accept(false)
            }
            if b {
                move(toNext: toNext)
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
            checkNextTitle.accept("Next")
            checkPrevTitle.accept("Prev")
            guard hasCurrent else {return}
            let o = currentItem!
            let isCorrect = o.WORD == wordInputString.value
            if isCorrect { arrCorrectIDs.append(o.ID) }
            MWordFami.update(wordid: o.WORDID, isCorrect: isCorrect).map { [unowned self] in
                o.CORRECT = $0.CORRECT
                o.TOTAL = $0.TOTAL
                accuracyString.accept(o.ACCURACY)
            }.subscribe() ~ rx.disposeBag
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
        accuracyHidden.accept(!isTestMode || !hasCurrent)
        checkNextEnabled.accept(hasCurrent)
        checkPrevEnabled.accept(hasCurrent)
        wordTargetString.accept(currentWord)
        noteTargetString.accept(currentItem?.NOTE ?? "")
        wordHintString.accept(String(currentItem?.WORD.count ?? 0))
        wordTargetHidden.accept(isTestMode)
        noteTargetHidden.accept(isTestMode)
        wordHintHidden.accept(!isTestMode || !hasCurrent)
        translationString.accept("")
        wordInputString.accept("")
        selectedWord = currentWord
        doTestAction?(self)
        if hasCurrent {
            indexString.accept("\(index + 1)/\(count)")
            accuracyString.accept(currentItem!.ACCURACY)
            getTranslation().subscribe { [unowned self] in
                translationString.accept($0)
            } ~ rx.disposeBag
        } else {
            stopTimer()
        }
    }

    func stopTimer() {
        subscriptionTimer?.dispose()
    }

    deinit {
        print("DEBUG: \(className) deinit")
        stopTimer()
    }
}
