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

class PhrasesReviewViewController: UIViewController {
    var vm: PhrasesReviewViewModel!
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var lblPhraseTarget: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblTranslation: UITextView!
    @IBOutlet weak var tfPhraseInput: UITextField!
    @IBOutlet weak var btnCheck: UIButton!
    
    var speakOrNot = false
    var shuffled = true
    var levelge0only = true
    var reviewMode = 0
    var subscription: Disposable? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = PhrasesReviewViewModel(settings: vmSettings)
        newTest(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        subscription?.dispose()
    }

    private func doTest() {
        let b = vm.hasNext()
        lblIndex.isHidden = !b
        lblCorrect.isHidden = true
        lblIncorrect.isHidden = true
        btnCheck.isEnabled = b
        btnCheck.titleLabel?.text = vm.isTestMode ? "Check" : "Next"
        lblPhraseTarget.text = vm.isTestMode ? "" : vm.currentPhrase
        lblTranslation.text = ""
        tfPhraseInput.text = ""
        tfPhraseInput.becomeFirstResponder()
        if b {
            lblIndex.text = "\(vm.index + 1)/\(vm.arrPhrases.count)"
            if speakOrNot {
                let utterance = AVSpeechUtterance(string: vm.currentPhrase)
                utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
                AppDelegate.synth.speak(utterance)
            }
        } else {
            subscription?.dispose()
        }
    }
    
    @IBAction func newTest(_ sender: AnyObject) {
        subscription?.dispose()
        vm.newTest(mode: ReviewMode(rawValue: reviewMode)!, shuffled: shuffled).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
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
            btnCheck.titleLabel?.text = "Next"
            vm.check(phraseInput: tfPhraseInput.text!)
        } else {
            vm.next()
            doTest()
            btnCheck.titleLabel?.text = "Check"
        }
    }
    
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
