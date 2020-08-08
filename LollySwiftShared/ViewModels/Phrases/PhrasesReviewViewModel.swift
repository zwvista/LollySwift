//
//  PhrasesReviewViewModel.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Foundation
import RxSwift

class PhrasesReviewViewModel: NSObject {

    var vmSettings: SettingsViewModel
    var arrPhrases = [MUnitPhrase]()
    var arrCorrectIDs = [Int]()
    var index = 0
    var mode: ReviewMode = .reviewAuto
    var isTestMode: Bool { mode == .test }
    var subscription: Disposable? = nil
    var isSpeaking = true
    let options = MReviewOptions()
    let doTestAction: (() -> Void)?

    @objc dynamic var indexString = ""
    @objc dynamic var indexHidden = false
    @objc dynamic var correctHidden = true
    @objc dynamic var incorrectHidden = true
    @objc dynamic var checkEnabled = false
    @objc dynamic var phraseTargetString = ""
    @objc dynamic var phraseTargetHidden = false
    @objc dynamic var translationString = ""
    @objc dynamic var phraseInputString = ""
    @objc dynamic var checkTitle = "Check"

    init(settings: SettingsViewModel, needCopy: Bool, doTestAction: (() -> Void)? = nil) {
        self.vmSettings = !needCopy ? settings : SettingsViewModel(settings)
        self.doTestAction = doTestAction
        options.shuffled = true
    }

    func newTest() {
        MUnitPhrase.getDataByTextbook(vmSettings.selectedTextbook, unitPartFrom: vmSettings.USUNITPARTFROM, unitPartTo: vmSettings.USUNITPARTTO).subscribe(onNext: {
            self.arrPhrases = $0
            let count = self.arrPhrases.count
            let from = count * (self.options.groupSelected - 1) / self.options.groupCount
            let to = count * self.options.groupSelected / self.options.groupCount
            self.arrPhrases = [MUnitPhrase](self.arrPhrases[from..<to])
            if self.options.shuffled { self.arrPhrases = self.arrPhrases.shuffled() }
            self.arrCorrectIDs = []
            self.index = 0
            self.subscription?.dispose()
            self.doTest()
            self.checkTitle = self.isTestMode ? "Check" : "Next"
            if self.mode == .reviewAuto {
                self.subscription = Observable<Int>.interval(DispatchTimeInterval.seconds(self.options.interval), scheduler: MainScheduler.instance).subscribe { _ in
                    self.check()
                }
                self.subscription?.disposed(by: self.rx.disposeBag)
            }
        }) ~ self.rx.disposeBag
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
            next()
            doTest()
        } else if correctHidden && incorrectHidden {
            phraseInputString = vmSettings.autoCorrectInput(text: phraseInputString)
            phraseTargetHidden = false
            if phraseInputString == currentPhrase {
                correctHidden = false
            } else {
                incorrectHidden = false
            }
            checkTitle = "Next"
            guard hasNext else {return}
            let o = arrPhrases[index]
            let isCorrect = o.PHRASE == phraseInputString
            if isCorrect { arrCorrectIDs.append(o.ID) }
        } else {
            next()
            doTest()
            checkTitle = "Check"
        }
    }
    
    func doTest() {
        indexHidden = !hasNext
        correctHidden = true
        incorrectHidden = true
        checkEnabled = hasNext
        phraseTargetString = currentPhrase
        translationString = currentItem?.TRANSLATION ?? ""
        phraseTargetHidden = isTestMode
        phraseInputString = ""
        doTestAction?()
        if hasNext {
            indexString = "\(index + 1)/\(arrPhrases.count)"
        } else {
            subscription?.dispose()
        }
    }
}
