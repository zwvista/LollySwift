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
    var isSpeaking = true
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
    }
    
    // Take a reference to the window controller in order to prevent it from being released
    // Otherwise, we would not be able to access its controls afterwards
    var wc: WordsReviewWindowController!
    override func viewDidAppear() {
        super.viewDidAppear()
        wc = view.window!.windowController as? WordsReviewWindowController
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
            if isSpeaking {
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
        let optionsVC = NSStoryboard(name: "Tools", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.mode = vm.mode.rawValue
        optionsVC.shuffled = shuffled
        optionsVC.levelge0only = levelge0only
        optionsVC.complete = { [unowned self] in
            self.vm.mode = ReviewMode(rawValue: optionsVC.pubMode.indexOfSelectedItem)!
            self.shuffled = optionsVC.shuffled
            self.levelge0only = optionsVC.levelge0only!
            self.subscription?.dispose()
            self.vm.newTest(shuffled: self.shuffled, levelge0only: self.levelge0only).subscribe {
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
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if isSpeaking {
            synth.startSpeaking(vm.currentWord)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsReviewWindowController: NSWindowController {
    
    @IBOutlet weak var scSpeak: NSSegmentedControl!

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
