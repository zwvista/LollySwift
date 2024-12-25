//
//  WordsReviewViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding
import AVFAudio

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
            if vm2.hasCurrent && vm2.isSpeaking.value {
                let dialogue = AVSpeechUtterance(string: vm2.currentWord)
                dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
                synth.speak(dialogue)
            }
            if vm2.needSearchDict {
                searchDict(self)
            }
            updateStatusText()
        }
        super.settingsChanged()

        _ = vm.indexString ~> tfIndex.rx.text.orEmpty
        _ = vm.indexHidden ~> tfIndex.rx.isHidden
        _ = vm.correctHidden ~> tfCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> tfIncorrect.rx.isHidden
        _ = vm.accuracyString ~> tfAccuracy.rx.text.orEmpty
        _ = vm.accuracyHidden ~> tfAccuracy.rx.isHidden
        _ = vm.checkNextEnabled ~> btnCheckNext.rx.isEnabled
        _ = vm.checkNextTitle ~> btnCheckNext.rx.title
        _ = vm.checkPrevEnabled ~> btnCheckPrev.rx.isEnabled
        _ = vm.checkPrevTitle ~> btnCheckPrev.rx.title
        _ = vm.checkPrevHidden ~> btnCheckPrev.rx.isHidden
        _ = vm.wordTargetString ~> tfWordTarget.rx.text.orEmpty
        _ = vm.noteTargetString ~> tfNoteTarget.rx.text.orEmpty
        _ = vm.wordHintString ~> tfWordHint.rx.text.orEmpty
        _ = vm.wordTargetHidden ~> tfWordTarget.rx.isHidden
        _ = vm.noteTargetHidden ~> tfNoteTarget.rx.isHidden
        _ = vm.wordHintHidden ~> tfWordHint.rx.isHidden
        _ = vm.translationString ~> tfTranslation.rx.text.orEmpty
        _ = vm.wordInputString <~> tfWordInput.rx.text.orEmpty
        _ = vm.onRepeat <~> scOnRepeat.rx.isOn
        _ = vm.moveForward <~> scMoveForward.rx.isOn
        _ = vm.onRepeatHidden ~> scOnRepeat.rx.isHidden
        _ = vm.moveForwardHidden ~> scMoveForward.rx.isHidden

        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        settingsChanged()
        wc = view.window!.windowController as? WordsReviewWindowController
        _ = vm.isSpeaking <~> scSpeak.rx.isOn
        vm.isSpeaking.subscribe { [unowned self] isSpeaking in
            if vm.hasCurrent && isSpeaking {
                let dialogue = AVSpeechUtterance(string: vm.currentWord)
                dialogue.voice = AVSpeechSynthesisVoice(identifier: vmSettings.macVoiceName)
                synth.speak(dialogue)
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
        guard textfield === tfWordInput, !(vm.isTestMode && vm.wordInputString.value.isEmpty) else {return}
        vm.check(toNext: true)
    }

    @IBAction func check(_ sender: NSButton) {
        vm.check(toNext: sender == btnCheckNext)
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(vm.arrWords.count) Words in \(vmSettings.UNITPARTINFO)"
    }
}

class WordsReviewWindowController: WordsBaseWindowController {
}
