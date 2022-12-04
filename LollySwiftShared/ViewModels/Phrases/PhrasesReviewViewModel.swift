//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation

class PhrasesReviewViewModel: NSObject, ObservableObject {

    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var count: Int { arrPhrases.count }
    var arrCorrectIDs = [Int]()
    var index = 0
    let options = MReviewOptions()
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var subscriptionTimer: Disposable? = nil
    let doTestAction: (() -> Void)?

    @Published var indexString = ""
    @Published var indexHidden = false
    @Published var correctHidden = true
    @Published var incorrectHidden = true
    @Published var checkNextEnabled = false
    @Published var checkNextTitle = "Check"
    @Published var checkPrevEnabled = false
    @Published var checkPrevTitle = "Check"
    @Published var checkPrevHidden = false
    @Published var phraseTargetString = ""
    @Published var phraseTargetHidden = false
    @Published var translationString = ""
    @Published var phraseInputString = ""
    @Published var isSpeaking = true
    @Published var moveForward = true
    @Published var onRepeat = true
    @Published var moveForwardHidden = false
    @Published var onRepeatHidden = false

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: (() -> Void)? = nil) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.doTestAction = doTestAction
        options.shuffled = true
    }

    func newTest() async {
        func f() {
            index = options.moveForward ? 0 : count - 1
            doTest()
            checkNextTitle = isTestMode ? "Check" : "Next"
            checkPrevTitle = isTestMode ? "Check" : "Prev"
        }
        index = 0
        arrPhrases.removeAll()
        arrCorrectIDs.removeAll()
        subscriptionTimer?.dispose()
        isSpeaking = options.speakingEnabled
        moveForward = options.moveForward
        moveForwardHidden = isTestMode
        onRepeat = !isTestMode && options.onRepeat
        onRepeatHidden = isTestMode
        checkPrevHidden = isTestMode
        if options.mode == .textbook {
            let arr = await MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook)
            let cnt = min(options.reviewCount, arr.count)
            arrPhrases = Array(arr.shuffled()[0..<cnt])
            f()
        } else {
            arrPhrases = await MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO)
            let from = count * (options.groupSelected - 1) / options.groupCount
            let to = count * options.groupSelected / options.groupCount
            arrPhrases = [MUnitPhrase](arrPhrases[from..<to])
            if options.shuffled { arrPhrases = arrPhrases.shuffled() }
            f()
            if options.mode == .reviewAuto {
                subscriptionTimer = Observable<Int>.interval(.seconds(self.options.interval), scheduler: MainScheduler.instance).subscribe { _ in
                    self.check(toNext: true)
                }
                self.subscriptionTimer?.disposed(by: self.rx.disposeBag)
            }
        }
    }

    var hasCurrent: Bool { !arrPhrases.isEmpty && (onRepeat || 0..<count ~= index) }
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
