//
//  PhrasesReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class PhrasesReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    var vm: PhrasesReviewViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfPhraseTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfPhraseInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    @objc var phraseInput = ""
    
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false
    var shuffled = true
    var reviewMode = 0
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    override func viewWillDisappear() {
        subscription?.dispose()
    }
    
    private func doTest() {
        let b = vm.hasNext()
        tfIndex.isHidden = !b
        tfCorrect.isHidden = true
        tfIncorrect.isHidden = true
        btnCheck.isEnabled = b
        btnCheck.title = vm.isTestMode ? "Check" : "Next"
        tfPhraseTarget.stringValue = vm.isTestMode ? "" : vm.currentPhrase
        tfTranslation.stringValue = ""
        phraseInput = ""
        tfPhraseInput.stringValue = ""
        tfPhraseInput.becomeFirstResponder()
        if b {
            tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrPhrases.count)"
            if speakOrNot {
                synth.startSpeaking(vm.currentPhrase)
            }
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: Any) {
        subscription?.dispose()
        vm.newTest(mode: ReviewMode(rawValue: reviewMode)!, shuffled: shuffled).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
        if vm.mode == .reviewAuto {
            subscription = Observable<Int>.interval(vmSettings.USREVIEWINTERVAL.toDouble / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
                self.check(self)
            }
            subscription?.disposed(by: disposeBag)
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if textfield === tfPhraseInput && (!vm.isTestMode || !phraseInput.isEmpty) {
            check(self)
        }
    }
    
    @IBAction func check(_ sender: Any) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if tfCorrect.isHidden && tfIncorrect.isHidden {
            phraseInput = vmSettings.autoCorrectInput(text: phraseInput)
            tfPhraseInput.stringValue = phraseInput
            tfPhraseTarget.isHidden = false
            tfPhraseTarget.stringValue = vm.currentPhrase
            if phraseInput == vm.currentPhrase {
                tfCorrect.isHidden = false
            } else {
                tfIncorrect.isHidden = false
            }
            btnCheck.title = "Next"
            vm.check(phraseInput: phraseInput)
        } else {
            vm.next()
            doTest()
            btnCheck.title = "Check"
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            synth.startSpeaking(vm.currentPhrase)
        }
    }
    
    @IBAction func fixedOrNotChanged(_ sender: Any) {
        shuffled = (sender as! NSSegmentedControl).selectedSegment == 1
    }
    
    @IBAction func reviewModeChanged(_ sender: Any) {
        reviewMode = (sender as! NSPopUpButton).indexOfSelectedItem
        newTest(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
