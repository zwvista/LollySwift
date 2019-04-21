//
//  WordsTestViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/04/15.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

class WordsTestViewController: NSViewController, LollyProtocol, NSTextFieldDelegate {
    var vm: WordsTestViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var tfIndex: NSTextField!
    @IBOutlet weak var tfCorrect: NSTextField!
    @IBOutlet weak var tfIncorrect: NSTextField!
    @IBOutlet weak var tfWordTarget: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!
    @IBOutlet weak var tfWordInput: NSTextField!
    
    @objc var wordInput = ""
    
    let synth = NSSpeechSynthesizer()
    var speakOrNot = false

    func settingsChanged() {
        vm = WordsTestViewModel(settings: AppDelegate.theSettingsViewModel)
        synth.setVoice(NSSpeechSynthesizer.VoiceName(rawValue: vmSettings.macVoiceName))
        newTest(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        settingsChanged()
    }
    
    private func doTest() {
        tfIndex.stringValue = "\(vm.index + 1)/\(vm.arrWords.count)"
        tfCorrect.isHidden = true
        tfIncorrect.isHidden = true
        tfWordTarget.stringValue = ""
        wordInput = ""
        tfWordInput.stringValue = ""
        tfWordInput.becomeFirstResponder()
        if speakOrNot {
            synth.startSpeaking(vm.currentWord)
        }
        vm.getTranslation().subscribe(onNext: {
            self.tfTranslation.stringValue = $0
        }).disposed(by: disposeBag)
    }
    
    @IBAction func newTest(_ sender: Any) {
        vm.newTest().subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
    }
    
    @IBAction func next(_ sender: Any) {
        vm.next()
        doTest()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let textfield = obj.object as! NSControl
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if textfield === tfWordInput && !wordInput.isEmpty {
            if tfCorrect.isHidden && tfIncorrect.isHidden {
                check(self)
            } else {
                next(self)
            }
        }
    }
    
    @IBAction func check(_ sender: Any) {
        wordInput = vmSettings.autoCorrectInput(text: wordInput)
        tfWordInput.stringValue = wordInput
        if wordInput == vm.currentWord {
            tfCorrect.isHidden = false
        } else {
            tfIncorrect.isHidden = false
            tfWordTarget.isHidden = false
            tfWordTarget.stringValue = vm.currentWord
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: Any) {
        speakOrNot = (sender as! NSSegmentedControl).selectedSegment == 1
        if speakOrNot {
            synth.startSpeaking(vm.currentWord)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
