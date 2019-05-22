//
//  WordsReviewViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/05/22.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import AVFoundation
import DropDown

class WordsReviewViewController: UIViewController {
    var vm: WordsReviewViewModel!
    let disposeBag = DisposeBag()

    @IBOutlet weak var lblWordTarget: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    @IBOutlet weak var tvTranslation: UITextView!
    @IBOutlet weak var tfWordInput: UITextField!
    @IBOutlet weak var btnReviewMode: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var swSpeakOrNot: UISwitch!
    @IBOutlet weak var swFixedOrNot: UISwitch!
    @IBOutlet weak var swLevelge0OrNot: UISwitch!

    var speakOrNot = false
    var shuffled = true
    var levelge0only = true
    var reviewMode = 0
    var subscription: Disposable? = nil
    
    let ddReviewMode = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddReviewMode.anchorView = btnReviewMode
        ddReviewMode.dataSource = ["Review(Auto)", "Test", "Review(Manual)"]
        ddReviewMode.selectionAction = { (index: Int, item: String) in
            self.reviewMode = index
            self.btnReviewMode.titleLabel?.text = item
            self.newTest(self)
        }
        
        vm = WordsReviewViewModel(settings: vmSettings)
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
        lblAccuracy.isHidden = !vm.isTestMode || !b
        btnCheck.isEnabled = b
        lblWordTarget.text = vm.isTestMode ? "" : vm.currentItem?.WORDNOTE ?? ""
        tvTranslation.text = ""
        tfWordInput.text = ""
        tfWordInput.becomeFirstResponder()
        if b {
            lblIndex.text = "\(vm.index + 1)/\(vm.arrWords.count)"
            lblAccuracy.text = vm.currentItem!.ACCURACY
            if speakOrNot {
                let utterance = AVSpeechUtterance(string: vm.currentWord)
                utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
                AppDelegate.synth.speak(utterance)
            }
            vm.getTranslation().subscribe(onNext: {
                self.tvTranslation.text = $0
            }).disposed(by: disposeBag)
        } else {
            subscription?.dispose()
        }
    }

    @IBAction func newTest(_ sender: AnyObject) {
        subscription?.dispose()
        vm.newTest(mode: ReviewMode(rawValue: reviewMode)!, shuffled: shuffled, levelge0only: levelge0only).subscribe {
            self.doTest()
        }.disposed(by: disposeBag)
        btnCheck.titleLabel?.text = vm.isTestMode ? "Check" : "Next"
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
            tfWordInput.text = vmSettings.autoCorrectInput(text: tfWordInput.text!)
            lblWordTarget.isHidden = false
            lblWordTarget.text = vm.currentWord
            if tfWordInput.text == vm.currentWord {
                lblCorrect.isHidden = false
            } else {
                lblIncorrect.isHidden = false
            }
            btnCheck.titleLabel?.text = "Next"
            vm.check(wordInput: tfWordInput.text!).subscribe().disposed(by: disposeBag)
        } else {
            vm.next()
            doTest()
            btnCheck.titleLabel?.text = "Check"
        }
    }
    
    @IBAction func speakOrNotChanged(_ sender: AnyObject) {
        speakOrNot = (sender as! UISwitch).isOn
        if speakOrNot {
            let utterance = AVSpeechUtterance(string: vm.currentWord)
            utterance.voice = AVSpeechSynthesisVoice(identifier: vmSettings.selectediOSVoice.VOICENAME)
            AppDelegate.synth.speak(utterance)
        }
    }
    
    @IBAction func fixedOrNotChanged(_ sender: AnyObject) {
        shuffled = (sender as! UISwitch).isOn
    }
    
    @IBAction func levelAllOrNotChanged(_ sender: AnyObject) {
        levelge0only = (sender as! UISwitch).isOn
    }
    
    @IBAction func reviewModeChanged(_ sender: AnyObject) {
        ddReviewMode.show()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
