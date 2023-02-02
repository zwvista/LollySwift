//
//  PhrasesReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class PhrasesReviewViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    @objc dynamic var vm: PhrasesReviewViewModel!

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

    var vmSettings: SettingsViewModel { vm.vmSettings }
    let synth = NSSpeechSynthesizer()

    func settingsChanged() {
        vm?.stopTimer()
        vm = PhrasesReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] vm2 in
            tfPhraseInput.becomeFirstResponder()
            if vm2.hasCurrent && vm2.isSpeaking.value {
               synth.startSpeaking(vm2.currentPhrase)
            }
        }
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))

        _ = vm.indexString ~> tfIndex.rx.text.orEmpty
        _ = vm.indexHidden ~> tfIndex.rx.isHidden
        _ = vm.correctHidden ~> tfCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> tfIncorrect.rx.isHidden
        _ = vm.checkNextEnabled ~> btnCheckNext.rx.isEnabled
        _ = vm.checkNextTitle ~> btnCheckNext.rx.title
        _ = vm.checkPrevEnabled ~> btnCheckPrev.rx.isEnabled
        _ = vm.checkPrevTitle ~> btnCheckPrev.rx.title
        _ = vm.checkPrevHidden ~> btnCheckPrev.rx.isHidden
        _ = vm.phraseTargetString ~> tfPhraseTarget.rx.text.orEmpty
        _ = vm.phraseTargetHidden ~> tfPhraseTarget.rx.isHidden
        _ = vm.translationString ~> tfTranslation.rx.text.orEmpty
        _ = vm.phraseInputString <~> tfPhraseInput.rx.text.orEmpty
        _ = vm.onRepeat <~> scOnRepeat.rx.isOn
        _ = vm.moveForward <~> scMoveForward.rx.isOn
        _ = vm.onRepeatHidden ~> scOnRepeat.rx.isHidden
        _ = vm.moveForwardHidden ~> scMoveForward.rx.isHidden

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
        vm.isSpeaking.subscribe { [unowned self] isSpeaking in
            if isSpeaking {
                synth.startSpeaking(vm.currentPhrase)
            }
        } ~ rx.disposeBag
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
            vm.newTest()
        }
        presentAsSheet(optionsVC)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfPhraseInput, !(vm.isTestMode && vm.phraseInputString.value.isEmpty) else {return}
        vm.check(toNext: true)
    }

    @IBAction func check(_ sender: NSButton) {
        vm.check(toNext: sender == btnCheckNext)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}

class PhrasesReviewWindowController: NSWindowController {

    @IBOutlet weak var scSpeak: NSSegmentedControl!

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
