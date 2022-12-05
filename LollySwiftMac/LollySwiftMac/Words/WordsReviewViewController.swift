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

    @objc dynamic var vm: WordsReviewViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    override var initSettingsInViewDidLoad: Bool { false }

    override func settingsChanged() {
        vm = WordsReviewViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) { [unowned self] in
            self.tfWordInput.becomeFirstResponder()
            if self.vm.hasCurrent && self.vm.isSpeaking {
                self.synth.startSpeaking(self.vm.currentWord)
            }
            if !self.vm.isTestMode {
                searchDict(self)
            }
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
        vm.isSpeaking.subscribe(onNext: { isSpeaking in
            if self.vm.hasCurrent && isSpeaking {
                self.synth.startSpeaking(self.vm.currentWord)
            }
        }) ~ rx.disposeBag
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
        wc = nil
        vm.subscriptionTimer?.dispose()
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
        vm.check(toNext: true)
    }
    
    @IBAction func check(_ sender: NSButton) {
        vm.check(toNext: sender == btnCheckNext)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}

class WordsReviewWindowController: WordsBaseWindowController {
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
