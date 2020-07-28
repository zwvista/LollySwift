//
//  PhrasesReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class PhrasesReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    var vm: PhrasesReviewViewModel!
    var vmSettings: SettingsViewModel { vm.vmSettings }

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfPhraseTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfPhraseInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    let options = MReviewOptions()
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
    var wc: PhrasesReviewWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? PhrasesReviewWindowController
        wc.scSpeak.selectedSegment = isSpeaking ? 1 : 0
        settingsChanged()
    }
    override func viewWillDisappear() {
        wc = nil
        subscription?.dispose()
    }
    
    private func doTest() {
        let b = vm.hasNext
        tfIndex.isHidden = !b
        tfCorrect.isHidden = true
        tfIncorrect.isHidden = true
        btnCheck.isEnabled = b
        tfPhraseTarget.stringValue = vm.currentPhrase
        tfTranslation.stringValue = vm.currentItem?.TRANSLATION ?? ""
        tfPhraseTarget.isHidden = vm.isTestMode
        tfPhraseInput.stringValue = ""
        tfPhraseInput.becomeFirstResponder()
        if b {
            tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrPhrases.count)"
            if isSpeaking {
                synth.startSpeaking(vm.currentPhrase)
            }
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options.copy(from: options)
        optionsVC.complete = { [unowned self] in
            self.options.copy(from: optionsVC.options)
            self.subscription?.dispose()
            self.vm.newTest(options: self.options).subscribe {
                self.doTest()
            } ~ self.rx.disposeBag
            self.btnCheck.title = self.vm.isTestMode ? "Check" : "Next"
            if self.vm.mode == .reviewAuto {
                self.subscription = Observable<Int>.interval(DispatchTimeInterval.milliseconds(self.vmSettings.USREVIEWINTERVAL), scheduler: MainScheduler.instance).subscribe { _ in
                    self.check(self)
                }
                self.subscription?.disposed(by: self.rx.disposeBag)
            }
        }
        self.presentAsSheet(optionsVC)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfPhraseInput, !(vm.isTestMode && tfPhraseInput.stringValue.isEmpty) else {return}
        check(self)
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if tfCorrect.isHidden && tfIncorrect.isHidden {
            tfPhraseInput.stringValue = vmSettings.autoCorrectInput(text: tfPhraseInput.stringValue)
            tfPhraseTarget.isHidden = false
            if tfPhraseInput.stringValue == vm.currentPhrase {
                tfCorrect.isHidden = false
            } else {
                tfIncorrect.isHidden = false
            }
            btnCheck.title = "Next"
            vm.check(phraseInput: tfPhraseTarget.stringValue)
        } else {
            vm.next()
            doTest()
            btnCheck.title = "Check"
        }
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if isSpeaking {
            synth.startSpeaking(vm.currentPhrase)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class PhrasesReviewWindowController: NSWindowController {
    
    @IBOutlet weak var scSpeak: NSSegmentedControl!

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
