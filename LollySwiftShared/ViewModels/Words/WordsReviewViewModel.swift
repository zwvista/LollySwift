//
//  WordsReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import Combine

class WordsReviewViewModel: WordsBaseViewModel {

    var arrWords = [MUnitWord]()
    var count: Int { arrWords.count }
    var arrCorrectIDs = [Int]()
    var index = 0
    var isTestMode: Bool { options.mode == .test || options.mode == .textbook }
    var subscriptionTimer: Cancellable? = nil
    let options = MReviewOptions()
    let doTestAction: (() -> Void)?

    @Published var indexString = ""
    @Published var indexHidden = false
    @Published var correctHidden = true
    @Published var incorrectHidden = true
    @Published var accuracyString = ""
    @Published var accuracyHidden = false
    @Published var checkNextEnabled = false
    @Published var checkNextTitle = "Check"
    @Published var checkPrevEnabled = false
    @Published var checkPrevTitle = "Check"
    @Published var checkPrevHidden = false
    @Published var wordTargetString = ""
    @Published var noteTargetString = ""
    @Published var wordHintString = ""
    @Published var wordTargetHidden = false
    @Published var noteTargetHidden = false
    @Published var wordHintHidden = false
    @Published var translationString = ""
    @Published var wordInputString = ""
    @Published var isSpeaking = true
    @Published var moveForward = true
    @Published var onRepeat = true
    @Published var moveForwardHidden = false
    @Published var onRepeatHidden = false

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: (() -> Void)? = nil) {
        self.doTestAction = doTestAction
        super.init(settings: settings, needCopy: needCopy)
        options.shuffled = true
    }

    func newTest() async {
        func f() async {
            index = options.moveForward ? 0 : count - 1
            await doTest()
            checkNextTitle = isTestMode ? "Check" : "Next"
            checkPrevTitle = isTestMode ? "Check" : "Prev"
        }
        index = 0
        arrWords.removeAll()
        arrCorrectIDs.removeAll()
        subscriptionTimer?.cancel()
        isSpeaking = options.speakingEnabled
        moveForward = options.moveForward
        moveForwardHidden = isTestMode
        onRepeat = !isTestMode && options.onRepeat
        onRepeatHidden = isTestMode
        checkPrevHidden = isTestMode
        if options.mode == .textbook {
            let arr = await MUnitWord.getDataByTextbook(vmSettings.selectedTextbook)
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
            await f()
        } else {
            arrWords = await MUnitWord.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO)
            let from = count * (options.groupSelected - 1) / options.groupCount
            let to = count * options.groupSelected / options.groupCount
            arrWords = [MUnitWord](arrWords[from..<to])
            if options.shuffled { arrWords = arrWords.shuffled() }
            await f()
            if options.mode == .reviewAuto {
                subscriptionTimer = Timer.publish(every: TimeInterval(options.interval), on: .main, in: .default)
                    .autoconnect()
                    .receive(on: DispatchQueue.main).sink { _ in
                    Task {
                        await self.check(toNext: true)
                    }
                }
            }
        }
    }

    var hasCurrent: Bool { !arrWords.isEmpty && (onRepeat || 0..<count ~= index) }
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
                arrWords = arrWords.filter { !arrCorrectIDs.contains($0.ID) }
            }
        } else {
            index -= 1
            checkOnRepeat()
        }
    }

    var currentItem: MUnitWord? { hasCurrent ? arrWords[index] : nil }
    var currentWord: String { hasCurrent ? arrWords[index].WORD : "" }
    func getTranslation() async -> String {
        guard vmSettings.hasDictTranslation else { return "" }
        let mDictTranslation = vmSettings.selectedDictTranslation
        let url = mDictTranslation.urlString(word: currentWord, arrAutoCorrect: vmSettings.arrAutoCorrect)
        let html = await RestApi.getHtml(url: url)
        print(html)
        return CommonApi.extractText(from: html, transform: mDictTranslation.TRANSFORM, template: "") { text,_ in text }
    }

    func check(toNext: Bool) async {
        if !isTestMode {
            var b = true
            if options.mode == .reviewManual && !wordInputString.isEmpty && wordInputString != currentWord {
                b = false
                incorrectHidden = false
            }
            if b {
                move(toNext: toNext)
                await doTest()
            }
        } else if correctHidden && incorrectHidden {
            wordInputString = vmSettings.autoCorrectInput(text: wordInputString)
            wordTargetHidden = false
            noteTargetHidden = false
            if wordInputString == currentWord {
                correctHidden = false
            } else {
                incorrectHidden = false
            }
            wordHintHidden = true
            checkNextTitle = "Next"
            checkPrevTitle = "Prev"
            guard hasCurrent else {return}
            let o = currentItem!
            let isCorrect = o.WORD == wordInputString
            if isCorrect { arrCorrectIDs.append(o.ID) }
            let o2 = await MWordFami.update(wordid: o.WORDID, isCorrect: isCorrect)
            o.CORRECT = o2.CORRECT
            o.TOTAL = o2.TOTAL
            self.accuracyString = o.ACCURACY
        } else {
            move(toNext: toNext)
            await doTest()
            checkNextTitle = "Check"
            checkPrevTitle = "Check"
        }
    }

    func doTest() async {
        indexHidden = !hasCurrent
        correctHidden = true
        incorrectHidden = true
        accuracyHidden = !isTestMode || !hasCurrent
        checkNextEnabled = hasCurrent
        checkPrevEnabled = hasCurrent
        wordTargetString = currentWord
        noteTargetString = currentItem?.NOTE ?? ""
        wordHintString = String(currentItem?.WORD.count ?? 0)
        wordTargetHidden = isTestMode
        noteTargetHidden = isTestMode
        wordHintHidden = !isTestMode || !hasCurrent
        translationString = ""
        wordInputString = ""
        selectedWord = currentWord
        doTestAction?()
        if hasCurrent {
            indexString = "\(index + 1)/\(count)"
            accuracyString = currentItem!.ACCURACY
            translationString = await getTranslation()
        } else {
            subscriptionTimer?.cancel()
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
        subscriptionTimer?.dispose()
    }
}
