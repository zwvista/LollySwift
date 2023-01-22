//
//  PhrasesReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import Combine

class PhrasesReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfPhraseTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfPhraseInput: NSTextField!
    @IBOutlet weak var btnCheckNext: NSButton!
    @IBOutlet weak var btnCheckPrev: NSButton!
    @IBOutlet weak var scOnRepeat: NSSegmentedControl!
    @IBOutlet weak var scMoveForward: NSSegmentedControl!

    @objc dynamic var vm: PhrasesReviewViewModel!
    var vmSettings: SettingsViewModel { vm.vmSettings }
    let synth = NSSpeechSynthesizer()
    var subscriptions = Set<AnyCancellable>()

    func settingsChanged() {
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] vm2 in
            tfPhraseInput.becomeFirstResponder()
            if vm2.hasCurrent && vm2.isSpeaking {
               synth.startSpeaking(vm2.currentPhrase)
            }
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))

        vm.$indexString ~> (tfIndex, \.stringValue) ~ subscriptions
        vm.$indexHidden ~> (tfIndex, \.isHidden) ~ subscriptions
        vm.$correctHidden ~> (tfCorrect, \.isHidden) ~ subscriptions
        vm.$incorrectHidden ~> (tfIncorrect, \.isHidden) ~ subscriptions
        vm.$checkNextEnabled ~> (btnCheckNext, \.isEnabled) ~ subscriptions
        vm.$checkNextTitle ~> (btnCheckNext, \.title) ~ subscriptions
        vm.$checkPrevEnabled ~> (btnCheckPrev, \.isEnabled) ~ subscriptions
        vm.$checkPrevTitle ~> (btnCheckPrev, \.title) ~ subscriptions
        vm.$checkPrevHidden ~> (btnCheckPrev, \.isHidden) ~ subscriptions
        vm.$phraseTargetString ~> (tfPhraseTarget, \.stringValue) ~ subscriptions
        vm.$phraseTargetHidden ~> (tfPhraseTarget, \.isHidden) ~ subscriptions
        vm.$translationString ~> (tfTranslation, \.stringValue) ~ subscriptions
        vm.$phraseInputString <~> tfPhraseInput.textProperty ~ subscriptions
        vm.$onRepeat <~> scOnRepeat.isOnProperty ~ subscriptions
        vm.$moveForward <~> scMoveForward.isOnProperty ~ subscriptions
        vm.$onRepeatHidden ~> (scOnRepeat, \.isHidden) ~ subscriptions
        vm.$moveForwardHidden ~> (scMoveForward, \.isHidden) ~ subscriptions

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
        vm.$isSpeaking <~> wc.scSpeak.isOnProperty ~ subscriptions
        vm.$isSpeaking.sink { isSpeaking in
            if isSpeaking {
                self.synth.startSpeaking(self.vm.currentPhrase)
            }
        } ~ subscriptions
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
        vm.stopTimer()
    }

    @IBAction func newTest(_ sender: AnyObject) {
        let optionsVC = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "ReviewOptionsViewController") as! ReviewOptionsViewController
        optionsVC.vm = ReviewOptionsViewModel(options: vm.options)
        optionsVC.complete = { [unowned self] in
            Task {
                await self.vm.newTest()
            }
        }
        self.presentAsSheet(optionsVC)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfPhraseInput, !(vm.isTestMode && vm.phraseInputString.isEmpty) else {return}
        vm.check(toNext: true)
    }

    @IBAction func check(_ sender: NSButton) {
        vm.check(toNext: sender == btnCheckNext)
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
