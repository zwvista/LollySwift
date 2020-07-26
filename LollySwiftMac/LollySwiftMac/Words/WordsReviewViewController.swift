//
//  WordsReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

class WordsReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    var vm: WordsReviewViewModel!
    var vmSettings: SettingsViewModel { vm.vmSettings }

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfNoteTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    let synth = NSSpeechSynthesizer()
    var isSpeaking = true
    let options = MReviewOptions()
    var subscription: Disposable? = nil

    func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Hold a reference to the window controller in order to prevent it from being released
    // Without it, we would not be able to access its child controls afterwards
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
        tfWordTarget.stringValue = vm.currentWord
        tfNoteTarget.stringValue = vm.currentItem?.NOTE ?? ""
        tfWordTarget.isHidden = vm.isTestMode
        tfNoteTarget.isHidden = vm.isTestMode
        tfTranslation.stringValue = ""
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
            }) ~ rx.disposeBag
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options.copy(from: options)
        optionsVC.options.mode = vm.mode.rawValue
        optionsVC.complete = { [unowned self] in
            self.options.copy(from: optionsVC.options)
            self.vm.mode = ReviewMode(rawValue: optionsVC.pubMode.indexOfSelectedItem)!
            self.subscription?.dispose()
            self.vm.newTest(options: self.options).subscribe {
                self.doTest()
            } ~ self.rx.disposeBag
            self.btnCheck.title = self.vm.isTestMode ? "Check" : "Next"
            if self.vm.mode == .reviewAuto {
                self.subscription = Observable<Int>.interval(DispatchTimeInterval.milliseconds( self.vmSettings.USREVIEWINTERVAL), scheduler: MainScheduler.instance).subscribe { _ in
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
        guard textfield === tfWordInput, !(vm.isTestMode && tfWordInput.stringValue.isEmpty) else {return}
        check(self)
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if tfCorrect.isHidden && tfIncorrect.isHidden {
            tfWordInput.stringValue = vmSettings.autoCorrectInput(text: tfWordInput.stringValue)
            tfWordTarget.isHidden = false
            tfNoteTarget.isHidden = false
            if tfWordInput.stringValue == vm.currentWord {
                tfCorrect.isHidden = false
            } else {
                tfIncorrect.isHidden = false
            }
            btnCheck.title = "Next"
            vm.check(wordInput: tfWordInput.stringValue).subscribe() ~ rx.disposeBag
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
