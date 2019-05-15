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
    var reviewMode = 0
    var isTestMode: Bool {
        return reviewMode == 2
    }
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel)
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
        tfAccuracy.isHidden = !isTestMode || !b
        btnCheck.isEnabled = b
        btnCheck.title = isTestMode ? "Check" : "Next"
        tfWordTarget.stringValue = isTestMode ? "" : vm.currentWord
        tfTranslation.stringValue = ""
        wordInput = ""
        tfWordInput.stringValue = ""
        tfWordInput.becomeFirstResponder()
        if b {
            tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrWords.count)"
            tfAccuracy.stringValue = vm.arrWords[vm.index].ACCURACY
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
    
    @IBAction func newTest(_ sender: Any) {
        subscription?.dispose()
        vm.newTest(shuffled: shuffled, levelge0only: levelge0only).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
        if reviewMode == 1 {
            subscription?.dispose()
            subscription = Observable<Int>.interval(3, scheduler: MainScheduler.instance).subscribe { _ in
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
        if textfield === tfWordInput && (!isTestMode || !wordInput.isEmpty) {
            check(self)
        }
    }
    
    @IBAction func check(_ sender: Any) {
        if !isTestMode {
            vm.next(isTestMode: isTestMode)
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
            vm.check(wordInput: wordInput).subscribe {
                
            }.disposed(by: disposeBag)
        } else {
            vm.next(isTestMode: isTestMode)
            doTest()
            btnCheck.title = "Check"
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            synth.startSpeaking(vm.currentWord)
        }
    }
    
    @IBAction func fixedOrNotChanged(_ sender: Any) {
        shuffled = (sender as! NSSegmentedControl).selectedSegment == 1
    }
    
    @IBAction func levelAllOrNotChanged(_ sender: Any) {
        levelge0only = (sender as! NSSegmentedControl).selectedSegment == 1
    }
    
    @IBAction func reviewModeChanged(_ sender: Any) {
        reviewMode = (sender as! NSPopUpButton).indexOfSelectedItem
        newTest(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
