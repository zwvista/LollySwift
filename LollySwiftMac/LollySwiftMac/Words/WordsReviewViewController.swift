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

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfNoteTarget: NSTextField!
    @IBOutlet weak var tfWordHint: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    @IBOutlet weak var btnSearch: NSButton!

    let synth = NSSpeechSynthesizer()

    func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            self.tfWordInput.becomeFirstResponder()
            if self.vm.hasNext && self.vm.isSpeaking.value {
                self.synth.startSpeaking(self.vm.currentWord)
            }
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vm.vmSettings.macVoiceName))
        
        _ = vm.indexString ~> tfIndex.rx.text.orEmpty
        _ = vm.indexHidden ~> tfIndex.rx.isHidden
        _ = vm.correctHidden ~> tfCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> tfIncorrect.rx.isHidden
        _ = vm.accuracyString ~> tfAccuracy.rx.text.orEmpty
        _ = vm.accuracyHidden ~> tfAccuracy.rx.isHidden
        _ = vm.checkEnabled ~> btnCheck.rx.isEnabled
        _ = vm.wordTargetString ~> tfWordTarget.rx.text.orEmpty
        _ = vm.noteTargetString ~> tfNoteTarget.rx.text.orEmpty
        _ = vm.wordHintString ~> tfWordHint.rx.text.orEmpty
        _ = vm.wordTargetHidden ~> tfWordTarget.rx.isHidden
        _ = vm.noteTargetHidden ~> tfNoteTarget.rx.isHidden
        _ = vm.wordHintHidden ~> tfWordHint.rx.isHidden
        _ = vm.translationString ~> tfTranslation.rx.text.orEmpty
        _ = vm.wordInputString <~> tfWordInput.rx.text.orEmpty
        _ = vm.checkTitle ~> btnCheck.rx.title
        _ = vm.searchEnabled ~> btnSearch.rx.isEnabled

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
        settingsChanged()
        wc = view.window!.windowController as? WordsReviewWindowController
        _ = vm.isSpeaking <~> wc.scSpeak.rx.isOn
        vm.isSpeaking.subscribe(onNext: { isSpeaking in
            if isSpeaking {
                self.synth.startSpeaking(self.vm.currentWord)
            }
        }) ~ rx.disposeBag
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
        vm.subscription?.dispose()
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.options = vm.options
        optionsVC.complete = { [unowned self] in
            self.vm.newTest()
        }
        self.presentAsSheet(optionsVC)
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfWordInput, !(vm.isTestMode && vm.wordInputString.value.isEmpty) else {return}
        vm.check()
    }
    
    @IBAction func check(_ sender: AnyObject) {
        vm.check()
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
