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
    @objc dynamic var vm: WordsReviewViewModel!
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
        wc.scSpeak.selectedSegment = vm.isSpeaking ? 1 : 0
        settingsChanged()
    }
    override func viewWillDisappear() {
        wc = nil
        vm.subscription?.dispose()
    }

    private func doTest() {
        vm.doTest()
        tfWordInput.becomeFirstResponder()
        if vm.hasNext {
            if vm.isSpeaking {
                synth.startSpeaking(vm.currentWord)
            }
        } else {
            vm.subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options.copy(from: vm.options)
        optionsVC.complete = { [unowned self] in
            self.vm.options.copy(from: optionsVC.options)
            self.vm.subscription?.dispose()
            self.vm.newTest(options: self.vm.options).subscribe {
                self.doTest()
            } ~ self.rx.disposeBag
            self.vm.checkTitle = self.vm.isTestMode ? "Check" : "Next"
            if self.vm.mode == .reviewAuto {
                self.vm.subscription = Observable<Int>.interval(DispatchTimeInterval.milliseconds( self.vmSettings.USREVIEWINTERVAL), scheduler: MainScheduler.instance).subscribe { _ in
                    self.check(self)
                }
                self.vm.subscription?.disposed(by: self.rx.disposeBag)
            }
        }
        self.presentAsSheet(optionsVC)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfWordInput, !(vm.isTestMode && vm.wordInputString.isEmpty) else {return}
        check(self)
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if vm.correctHidden && vm.incorrectHidden {
            vm.wordInputString = vmSettings.autoCorrectInput(text: vm.wordInputString)
            vm.wordTargetHidden = false
            vm.noteTargetHidden = false
            if vm.wordInputString == vm.currentWord {
                vm.correctHidden = false
            } else {
                vm.incorrectHidden = false
            }
            vm.checkTitle = "Next"
            vm.check(wordInput: vm.wordInputString).subscribe() ~ rx.disposeBag
        } else {
            vm.next()
            doTest()
            vm.checkTitle = "Check"
        }
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        vm.isSpeaking = (sender as! NSSegmentedControl).selectedSegment == 1
        if vm.isSpeaking {
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
