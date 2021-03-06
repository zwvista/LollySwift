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
    
    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblPhraseTarget: UILabel!
    @IBOutlet weak var lblTranslation: UILabel!
    @IBOutlet weak var tfPhraseInput: UITextField!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var btnCheckNext: UIButton!
    @IBOutlet weak var btnCheckPrev: UIButton!
    @IBOutlet weak var swSpeak: UISwitch!
    @IBOutlet weak var swOnRepeat: UISwitch!
    @IBOutlet weak var swMoveForward: UISwitch!
    @IBOutlet weak var svSpeak: UIStackView!
    @IBOutlet weak var svOnRepeat: UIStackView!
    @IBOutlet weak var svMoveForward: UIStackView!

    var isSpeaking = false
    
    let ddReviewMode = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = PhrasesReviewViewModel(settings: vmSettings, needCopy: false) { [unowned self] in
            self.tfPhraseInput.becomeFirstResponder()
            if self.vm.hasCurrent && self.vm.isSpeaking.value {
                AppDelegate.speak(string: self.vm.currentPhrase)
            }
        }
        
        _ = vm.indexString ~> lblIndex.rx.text
        _ = vm.indexHidden ~> lblIndex.rx.isHidden
        _ = vm.correctHidden ~> lblCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> lblIncorrect.rx.isHidden
        _ = vm.checkNextEnabled ~> btnCheckNext.rx.isEnabled
        _ = vm.checkNextTitle ~> btnCheckNext.rx.title(for: .normal)
        _ = vm.checkPrevEnabled ~> btnCheckPrev.rx.isEnabled
        _ = vm.checkPrevTitle ~> btnCheckPrev.rx.title(for: .normal)
        _ = vm.checkPrevHidden ~> btnCheckPrev.rx.isHidden
        _ = vm.phraseTargetString ~> lblPhraseTarget.rx.text
        _ = vm.phraseTargetHidden ~> lblPhraseTarget.rx.isHidden
        _ = vm.translationString ~> lblTranslation.rx.text
        _ = vm.phraseInputString <~> tfPhraseInput.rx.text.orEmpty
        _ = vm.isSpeaking ~> swSpeak.rx.isOn
        _ = vm.onRepeat <~> swOnRepeat.rx.isOn
        _ = vm.moveForward <~> swMoveForward.rx.isOn
        _ = vm.onRepeatHidden ~> svOnRepeat.rx.isHidden
        _ = vm.moveForwardHidden ~> svMoveForward.rx.isHidden

        newTest(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.subscriptionTimer?.dispose()
    }

    @IBAction func newTest(_ sender: AnyObject) {
        performSegue(withIdentifier: "options", sender: sender)
    }
    
    @IBAction func check(_ sender: UIButton) {
        vm.check(toNext: sender == btnCheckNext)
    }

    @IBAction func isSpeakingChanged(_ sender: AnyObject) {
        if isSpeaking {
            speak(sender)
        }
    }
    
    @IBAction func speak(_ sender: AnyObject) {
        AppDelegate.speak(string: vm.currentPhrase)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        vm.check(toNext: true)
        return false
    }
    
    // https://stackoverflow.com/questions/18755410/how-to-dismiss-keyboard-ios-programmatically-when-pressing-return
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let controller = (segue.destination as? UINavigationController)?.topViewController as? ReviewOptionsViewController {
            controller.options = vm.options
        }
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        guard segue.identifier == "Done" else {return}
        if let controller = segue.source as? ReviewOptionsViewController {
            controller.vm.onOK()
            vm.newTest()
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
