//
//  WordsReviewViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/05/22.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import RxSwift
import DropDown
import NSObject_Rx

class WordsReviewViewController: UIViewController, UITextFieldDelegate {
    var vm: WordsReviewViewModel!

    @IBOutlet weak var lblWordTarget: UILabel!
    @IBOutlet weak var lblNoteTarget: UILabel!
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    @IBOutlet weak var tvTranslation: UITextView!
    @IBOutlet weak var tfWordInput: UITextField!
    @IBOutlet weak var btnReviewMode: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var swSpeak: UISwitch!
    @IBOutlet weak var swShuffled: UISwitch!
    @IBOutlet weak var swLevelge0: UISwitch!

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
            self.vm.options.mode = ReviewMode(rawValue: index)!
            self.btnReviewMode.setTitle(item, for: .normal)
            self.newTest(self)
        }
        
        vm = WordsReviewViewModel(settings: vmSettings, needCopy: false)
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
        lblAccuracy.isHidden = !vm.isTestMode || !b
        btnCheck.isEnabled = b
        lblWordTarget.text = vm.currentWord
        lblNoteTarget.text = vm.currentItem?.NOTE ?? ""
        lblWordTarget.isHidden = vm.isTestMode
        lblNoteTarget.isHidden = vm.isTestMode
        tvTranslation.isHidden = false
        tvTranslation.text = ""
        tfWordInput.text = ""
        tfWordInput.isHidden = vm.options.mode == .reviewAuto
        if !tfWordInput.isHidden {
            tfWordInput.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        if b {
            lblIndex.text = "\(vm.index + 1)/\(vm.arrWords.count)"
            lblAccuracy.text = vm.currentItem!.ACCURACY
            if isSpeaking {
                AppDelegate.speak(string: vm.currentWord)
            }
            vm.getTranslation().subscribe(onNext: {
                self.tvTranslation.text = $0
            }) ~ rx.disposeBag
        } else {
            subscription?.dispose()
            tvTranslation.isHidden = true
            tfWordInput.isHidden = true
            view.endEditing(true)
        }
    }

    @IBAction func newTest(_ sender: AnyObject) {
        performSegue(withIdentifier: "options", sender: sender)
//        subscription?.dispose()
//        vm.newTest(shuffled: shuffled, levelge0only: levelge0only, groupSelected: 1, groupCount: 1).subscribe {
//            self.doTest()
//        } ~ rx.disposeBag
//        btnCheck.setTitle(vm.isTestMode ? "Check" : "Next", for: .normal)
//        if vm.mode == .reviewAuto {
//            subscription = Observable<Int>.interval(vmSettings.USREVIEWINTERVAL.toDouble / 1000.0, scheduler: MainScheduler.instance).subscribe { _ in
//                self.check(self)
//            }
//            subscription? ~ rx.disposeBag
//        }
    }
    
    @IBAction func check(_ sender: AnyObject) {
        if !vm.isTestMode {
            vm.next()
            doTest()
        } else if lblCorrect.isHidden && lblIncorrect.isHidden {
            tfWordInput.text = vmSettings.autoCorrectInput(text: tfWordInput.text!)
            lblWordTarget.isHidden = false
            lblNoteTarget.isHidden = false
            if tfWordInput.text == vm.currentWord {
                lblCorrect.isHidden = false
            } else {
                lblIncorrect.isHidden = false
            }
            btnCheck.setTitle("Next", for: .normal)
//            vm.check(wordInput: tfWordInput.text!).subscribe() ~ rx.disposeBag
        } else {
            vm.next()
            doTest()
            btnCheck.setTitle("Check", for: .normal)
        }
    }
    
    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        isSpeaking = (sender as! UISwitch).isOn
        if isSpeaking {
            AppDelegate.speak(string: vm.currentWord)
        }
    }
    
    @IBAction func shuffledOrNotChanged(_ sender: AnyObject) {
        shuffled = (sender as! UISwitch).isOn
    }
    
    @IBAction func levelAllOrNotChanged(_ sender: AnyObject) {
        levelge0only = (sender as! UISwitch).isOn
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
