//
//  PhrasesReviewViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/05/22.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import DropDown
import NSObject_Rx

class PhrasesReviewViewController: UIViewController, UITextFieldDelegate {
    var vm: PhrasesReviewViewModel!
    
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
    var options = MReviewOptions()
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
        super.viewWillDisappear(animated)
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
                AppDelegate.speak(string: vm.currentPhrase)
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
        vm.newTest(options: options).subscribe {
            self.doTest()
        } ~ rx.disposeBag
        btnCheck.setTitle(vm.isTestMode ? "Check" : "Next", for: .normal)
        if vm.mode == .reviewAuto {
            subscription = Observable<Int>.interval(DispatchTimeInterval.milliseconds(vmSettings.USREVIEWINTERVAL), scheduler: MainScheduler.instance).subscribe { _ in
                self.check(self)
            }
            subscription! ~ rx.disposeBag
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
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! UISwitch).isOn
        if isSpeaking {
            AppDelegate.speak(string: vm.currentPhrase)
        }
    }
    
    @IBAction func shuffledOrNotChanged(_ sender: AnyObject) {
        options.shuffled = (sender as! UISwitch).isOn
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
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        let controller = segue.source as! ReviewOptionsViewController
        controller.onDone()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
