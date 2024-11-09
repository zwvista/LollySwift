//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
@preconcurrency import Combine

@MainActor
class PhrasesReviewViewModel: NSObject, ObservableObject {

    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var count: Int { arrPhrases.count }
    var arrCorrectIDs = [Int]()
    var index = 0
    let options = MReviewOptions()
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var subscriptionTimer: Cancellable? = nil
    let doTestAction: ((PhrasesReviewViewModel) -> Void)?

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
    // https://stackoverflow.com/questions/70568987/it-is-possible-to-accessing-focusstates-value-outside-of-the-body-of-a-view
    @Published var inputFocused = false

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: ((PhrasesReviewViewModel) -> Void)? = nil) {
        vmSettings = !needCopy ? settings : SettingsViewModel(settings)
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
        stopTimer()
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
                subscriptionTimer = Timer.publish(every: TimeInterval(options.interval), on: .main, in: .default)
                    .autoconnect()
                    .receive(on: DispatchQueue.main).sink { [unowned self] _ in
                    check(toNext: true)
                }
            }
        }
    }

    var hasCurrent: Bool { !arrPhrases.isEmpty && (onRepeat || 0..<count ~= index) }
    func move(toNext: Bool) {
        func checkOnRepeat() {
            if onRepeat {
                index = (index + count) % count
            }
        }
        if moveForward == toNext {
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
            if options.mode == .reviewManual && !phraseInputString.isEmpty && phraseInputString != currentPhrase {
                b = false
                incorrectHidden = false
            }
            if b {
                move(toNext: toNext)
                doTest()
            }
        } else if correctHidden && incorrectHidden {
            phraseInputString = vmSettings.autoCorrectInput(text: phraseInputString)
            phraseTargetHidden = false
            if phraseInputString == currentPhrase {
                correctHidden = false
            } else {
                incorrectHidden = false
            }
            checkNextTitle = "Next"
            checkPrevTitle = "Prev"
            guard hasCurrent else {return}
            let o = arrPhrases[index]
            let isCorrect = o.PHRASE == phraseInputString
            if isCorrect { arrCorrectIDs.append(o.ID) }
        } else {
            move(toNext: toNext)
            doTest()
            checkNextTitle = "Check"
            checkPrevTitle = "Check"
        }
    }

    func doTest() {
        indexHidden = !hasCurrent
        correctHidden = true
        incorrectHidden = true
        checkNextEnabled = hasCurrent
        checkPrevEnabled = hasCurrent
        phraseTargetString = currentPhrase
        translationString = currentItem?.TRANSLATION ?? ""
        phraseTargetHidden = isTestMode
        phraseInputString = ""
        doTestAction?(self)
        if hasCurrent {
            indexString = "\(index + 1)/\(count)"
        } else {
            stopTimer()
        }
    }

    func stopTimer() {
        subscriptionTimer?.cancel()
    }

    deinit {
        print("DEBUG: \(className) deinit")
//        subscriptionTimer?.cancel()
    }
}
