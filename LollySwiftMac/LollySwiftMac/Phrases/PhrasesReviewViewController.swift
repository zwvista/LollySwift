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
    @objc dynamic var vm: PhrasesReviewViewModel!
    var vmSettings: SettingsViewModel { vm.vmSettings }

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfPhraseTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfPhraseInput: NSTextField!
    @IBOutlet weak var btnCheck: NSButton!
    
    let synth = NSSpeechSynthesizer()

    func settingsChanged() {
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            self.tfPhraseInput.becomeFirstResponder()
            if self.vm.hasNext && self.vm.isSpeaking.value {
               self.synth.startSpeaking(self.vm.currentPhrase)
            }
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        
        _ = vm.indexString ~> tfIndex.rx.text.orEmpty
        _ = vm.indexHidden ~> tfIndex.rx.isHidden
        _ = vm.correctHidden ~> tfCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> tfIncorrect.rx.isHidden
        _ = vm.checkEnabled ~> btnCheck.rx.isEnabled
        _ = vm.phraseTargetString ~> tfPhraseTarget.rx.text.orEmpty
        _ = vm.phraseTargetHidden ~> tfPhraseTarget.rx.isHidden
        _ = vm.translationString ~> tfTranslation.rx.text.orEmpty
        _ = vm.phraseInputString <~> tfPhraseInput.rx.text.orEmpty
        _ = vm.checkTitle ~> btnCheck.rx.title
        
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
        settingsChanged()
        wc = view.window!.windowController as? PhrasesReviewWindowController
        _ = vm.isSpeaking <~> wc.scSpeak.rx.isOn
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
        guard textfield === tfPhraseInput, !(vm.isTestMode && vm.phraseInputString.value.isEmpty) else {return}
        vm.check()
    }
    
    @IBAction func check(_ sender: AnyObject) {
        vm.check()
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        if vm.isSpeaking.value {
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
