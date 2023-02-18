//
//  WordsReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import Combine

class WordsReviewViewController: WordsBaseViewController, NSTextFieldDelegate {

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfAccuracy: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfNoteTarget: NSTextField!
    @IBOutlet weak var tfWordHint: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    @IBOutlet weak var btnCheckNext: NSButton!
    @IBOutlet weak var btnCheckPrev: NSButton!
    @IBOutlet weak var scOnRepeat: NSSegmentedControl!
    @IBOutlet weak var scMoveForward: NSSegmentedControl!

    var vm: WordsReviewViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    override var initSettingsInViewDidLoad: Bool { false }

    override func settingsChanged() {
        vm?.stopTimer()
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] vm2 in
            tfWordInput.becomeFirstResponder()
            if vm2.hasCurrent && vm2.isSpeaking {
                synth.startSpeaking(vm2.currentWord)
            }
            if !vm2.isTestMode {
                searchDict(self)
            }
            updateStatusText()
        }
        super.settingsChanged()

        vm.$indexString ~> (tfIndex, \.stringValue) ~ subscriptions
        vm.$indexHidden ~> (tfIndex, \.isHidden) ~ subscriptions
        vm.$correctHidden ~> (tfCorrect, \.isHidden) ~ subscriptions
        vm.$incorrectHidden ~> (tfIncorrect, \.isHidden) ~ subscriptions
        vm.$accuracyString ~> (tfAccuracy, \.stringValue) ~ subscriptions
        vm.$accuracyHidden ~> (tfAccuracy, \.isHidden) ~ subscriptions
        vm.$checkNextEnabled ~> (btnCheckNext, \.isEnabled) ~ subscriptions
        vm.$checkNextTitle ~> (btnCheckNext, \.title) ~ subscriptions
        vm.$checkPrevEnabled ~> (btnCheckPrev, \.isEnabled) ~ subscriptions
        vm.$checkPrevTitle ~> (btnCheckPrev, \.title) ~ subscriptions
        vm.$checkPrevHidden ~> (btnCheckPrev, \.isHidden) ~ subscriptions
        vm.$wordTargetString ~> (tfWordTarget, \.stringValue) ~ subscriptions
        vm.$noteTargetString ~> (tfNoteTarget, \.stringValue) ~ subscriptions
        vm.$wordHintString ~> (tfWordHint, \.stringValue) ~ subscriptions
        vm.$wordTargetHidden ~> (tfWordTarget, \.isHidden) ~ subscriptions
        vm.$noteTargetHidden ~> (tfNoteTarget, \.isHidden) ~ subscriptions
        vm.$wordHintHidden ~> (tfWordHint, \.isHidden) ~ subscriptions
        vm.$translationString ~> (tfTranslation, \.stringValue) ~ subscriptions
        vm.$wordInputString <~> tfWordInput.textProperty ~ subscriptions
        vm.$onRepeat <~> scOnRepeat.isOnProperty ~ subscriptions
        vm.$moveForward <~> scMoveForward.isOnProperty ~ subscriptions
        vm.$onRepeatHidden ~> (scOnRepeat, \.isHidden) ~ subscriptions
        vm.$moveForwardHidden ~> (scMoveForward, \.isHidden) ~ subscriptions

        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        settingsChanged()
        wc = view.window!.windowController as? WordsReviewWindowController
        vm.$isSpeaking <~> wc.scSpeak.isOnProperty ~ subscriptions
        vm.$isSpeaking.sink { [unowned self] isSpeaking in
            if vm.hasCurrent && isSpeaking {
                synth.startSpeaking(vm.currentWord)
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
                await vm.newTest()
            }
        }
        presentAsSheet(optionsVC)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let code = (obj.userInfo!["NSTextMovement"] as! NSNumber).intValue
        guard code == NSReturnTextMovement else {return}
        guard textfield === tfWordInput, !(vm.isTestMode && vm.wordInputString.isEmpty) else {return}
        Task {
            await vm.check(toNext: true)
        }
    }

    @IBAction func check(_ sender: NSButton) {
        Task {
            await vm.check(toNext: sender == btnCheckNext)
        }
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(vm.arrWords.count) Words in \(vmSettings.UNITINFO)"
    }
}

class WordsReviewWindowController: WordsBaseWindowController {
}
