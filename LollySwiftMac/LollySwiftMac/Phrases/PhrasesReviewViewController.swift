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
    var vmSettings: SettingsViewModel {
        return vm.vmSettings
    }
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
    var isSpeaking = true
    var shuffled = true
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Take a reference to the window controller in order to prevent it from being released
    // Otherwise, we would not be able to access its controls afterwards
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
        tfPhraseTarget.stringValue = vm.isTestMode ? "" : vm.currentPhrase
        tfTranslation.stringValue = ""
        phraseInput = ""
        tfPhraseInput.stringValue = ""
        tfPhraseInput.becomeFirstResponder()
        if b {
            tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrPhrases.count)"
            if isSpeaking {
                synth.startSpeaking(vm.currentPhrase)
            }
            tfTranslation.stringValue = vm.currentItem!.TRANSLATION ?? ""
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Tools", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.mode = vm.mode.rawValue
        optionsVC.shuffled = shuffled
        optionsVC.complete = { [unowned self] in
            self.vm.mode = ReviewMode(rawValue: optionsVC.pubMode.indexOfSelectedItem)!
            self.shuffled = optionsVC.shuffled
            self.subscription?.dispose()
            self.vm.newTest(shuffled: self.shuffled).subscribe {
                self.doTest()
            }.disposed(by: self.disposeBag)
            self.btnCheck.title = self.vm.isTestMode ? "Check" : "Next"
            if self.vm.mode == .reviewAuto {
                self.subscription = Observable<Int>.interval(self.vmSettings.USREVIEWINTERVAL.toDouble / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
                    self.check(self)
                }
                self.subscription?.disposed(by: self.disposeBag)
            }
        }
        self.presentAsSheet(optionsVC)
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
    
    @IBAction func check(_ sender: AnyObject) {
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
    
    @IBAction func speakOrNotChanged(_ sender: AnyObject) {
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
