//
//  PhrasesReviewViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/05/22.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation
import DropDown

class PhrasesReviewViewController: UIViewController, UITextFieldDelegate {
    var vm: PhrasesReviewViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var lblPhraseTarget: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var tfPhraseInput: UITextField!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnReviewMode: UIButton!
    @IBOutlet weak var swSpeak: UISwitch!
    @IBOutlet weak var swShuffled: UISwitch!

    var isSpeaking = false
    var shuffled = true
    var levelge0only = true
    var subscription: Disposable? = nil
    
    let ddReviewMode = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddReviewMode.anchorView = btnReviewMode
        ddReviewMode.dataSource = ["Review(Auto)", "Test", "Review(Manual)"]
        ddReviewMode.selectionAction = { [unowned self] (index: Int, item: String) in
            self.vm.mode = ReviewMode(rawValue: index)!
            // https://stackoverflow.com/questions/11417077/changing-uibutton-text
            self.btnReviewMode.setTitle(item, for: .normal)
            self.newTest(self)
        }

        vm = PhrasesReviewViewModel(settings: vmSettings, needCopy: false)
        newTest(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        subscription?.dispose()
    }

    private func doTest() {
        let b = vm.hasNext
        lblIndex.isHidden = !b
        lblCorrect.isHidden = true
        lblIncorrect.isHidden = true
        btnCheck.isEnabled = b
        lblPhraseTarget.text = vm.isTestMode ? "" : vm.currentPhrase
        lblTranslation.text = ""
        tfPhraseInput.text = ""
        tfPhraseInput.isHidden = vm.mode == .reviewAuto
        if !tfPhraseInput.isHidden {
            tfPhraseInput.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        if b {
            lblIndex.text = "\(vm.index + 1)/\(vm.arrPhrases.count)"
            if isSpeaking {
                let utterance = AVSpeechUtterance(string: vm.currentPhrase)
                utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
                AppDelegate.synth.speak(utterance)
            }
            lblTranslation.text = vm.currentItem!.TRANSLATION ?? ""
        } else {
            subscription?.dispose()
            tfPhraseInput.isHidden = true
            view.endEditing(true)
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        subscription?.dispose()
        vm.newTest(shuffled: shuffled).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
        btnCheck.setTitle(vm.isTestMode ? "Check" : "Next", for: .normal)
        if vm.mode == .reviewAuto {
            subscription = Observable<Int>.interval(vmSettings.USREVIEWINTERVAL.toDouble / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
                self.check(self)
            }
            subscription?.disposed(by: disposeBag)
        }
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if lblCorrect.isHidden && lblIncorrect.isHidden {
            tfPhraseInput.text = vmSettings.autoCorrectInput(text: tfPhraseInput.text!)
            lblPhraseTarget.isHidden = false
            lblPhraseTarget.text = vm.currentPhrase
            if tfPhraseInput.text == vm.currentPhrase {
                lblCorrect.isHidden = false
            } else {
                lblIncorrect.isHidden = false
            }
            btnCheck.setTitle("Next", for: .normal)
            vm.check(phraseInput: tfPhraseInput.text!)
        } else {
            vm.next()
            doTest()
            btnCheck.setTitle("Check", for: .normal)
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! UISwitch).isOn
        if isSpeaking {
            let utterance = AVSpeechUtterance(string: vm.currentPhrase)
            utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
            AppDelegate.synth.speak(utterance)
        }
    }
    
    @IBAction func shuffledOrNotChanged(_ sender: AnyObject) {
        shuffled = (sender as! UISwitch).isOn
    }
    
    @IBAction func reviewModeChanged(_ sender: AnyObject) {
        ddReviewMode.show()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        check(self)
        return false
    }
    
    // https://stackoverflow.com/questions/18755410/how-to-dismiss-keyboard-ios-programmatically-when-pressing-return
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
