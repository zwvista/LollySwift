//
//  WordsReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    var vm: WordsReviewViewModel!
    var vmSettings: SettingsViewModel {
        return vm.vmSettings
    }
    let disposeBag = DisposeBag()

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    @objc var wordInput = ""
    
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false
    var shuffled = true
    var levelge0only = true
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true)
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
        let b = vm.hasNext
        tfIndex.isHidden = !b
        tfCorrect.isHidden = true
        tfIncorrect.isHidden = true
        tfAccuracy.isHidden = !vm.isTestMode || !b
        btnCheck.isEnabled = b
        tfWordTarget.stringValue = vm.isTestMode ? "" : vm.currentItem?.WORDNOTE ?? ""
        tfTranslation.stringValue = ""
        wordInput = ""
        tfWordInput.stringValue = ""
        tfWordInput.becomeFirstResponder()
        if b {
            tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrWords.count)"
            tfAccuracy.stringValue = vm.currentItem!.ACCURACY
            if speakOrNot {
                synth.startSpeaking(vm.currentWord)
            }
            vm.getTranslation().subscribe(onNext: {
                self.tfTranslation.stringValue = $0
            }).disposed(by: disposeBag)
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        subscription?.dispose()
        vm.newTest(shuffled: shuffled, levelge0only: levelge0only).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
        btnCheck.title = vm.isTestMode ? "Check" : "Next"
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
        if textfield === tfWordInput && (!vm.isTestMode || !wordInput.isEmpty) {
            check(self)
        }
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if tfCorrect.isHidden && tfIncorrect.isHidden {
            wordInput = vmSettings.autoCorrectInput(text: wordInput)
            tfWordInput.stringValue = wordInput
            tfWordTarget.isHidden = false
            tfWordTarget.stringValue = vm.currentWord
            if wordInput == vm.currentWord {
                tfCorrect.isHidden = false
            } else {
                tfIncorrect.isHidden = false
            }
            btnCheck.title = "Next"
            vm.check(wordInput: wordInput).subscribe().disposed(by: disposeBag)
        } else {
            vm.next()
            doTest()
            btnCheck.title = "Check"
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: AnyObject) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            synth.startSpeaking(vm.currentWord)
        }
    }
    
    @IBAction func shuffledOrNotChanged(_ sender: AnyObject) {
        shuffled = (sender as! NSSegmentedControl).selectedSegment == 1
    }
    
    @IBAction func levelAllOrNotChanged(_ sender: AnyObject) {
        levelge0only = (sender as! NSSegmentedControl).selectedSegment == 1
    }
    
    @IBAction func reviewModeChanged(_ sender: AnyObject) {
        vm.mode = ReviewMode(rawValue: (sender as! NSPopUpButton).indexOfSelectedItem)!
        newTest(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
