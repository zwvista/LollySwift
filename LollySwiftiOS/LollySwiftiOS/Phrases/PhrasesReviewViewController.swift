//
//  PhrasesReviewViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2019/05/22.
//  Copyright © 2019 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import Combine

class PhrasesReviewViewController: UIViewController, UITextFieldDelegate {
    
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

    var vm: PhrasesReviewViewModel!
    var isSpeaking = false
    let ddReviewMode = DropDown()
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = PhrasesReviewViewModel(settings: vmSettings, needCopy: false) { [unowned self] in
            self.tfPhraseInput.becomeFirstResponder()
            if self.vm.hasCurrent && self.vm.isSpeaking {
                AppDelegate.speak(string: self.vm.currentPhrase)
            }
        }
        
        vm.$indexString ~> (lblIndex, \.text!) ~ subscriptions
        vm.$indexHidden ~> (lblIndex, \.isHidden) ~ subscriptions
        vm.$correctHidden ~> (lblCorrect, \.isHidden) ~ subscriptions
        vm.$incorrectHidden ~> (lblIncorrect, \.isHidden) ~ subscriptions
        vm.$checkNextEnabled ~> (btnCheckNext, \.isEnabled) ~ subscriptions
        vm.$checkNextTitle ~> (btnCheckNext, \.titleNormal) ~ subscriptions
        vm.$checkPrevEnabled ~> (btnCheckPrev, \.isEnabled) ~ subscriptions
        vm.$checkPrevTitle ~> (btnCheckPrev, \.titleNormal) ~ subscriptions
        vm.$checkPrevHidden ~> (btnCheckPrev, \.isHidden) ~ subscriptions
        vm.$phraseTargetString ~> (lblPhraseTarget, \.text!) ~ subscriptions
        vm.$phraseTargetHidden ~> (lblPhraseTarget, \.isHidden) ~ subscriptions
        vm.$translationString ~> (lblTranslation, \.text!) ~ subscriptions
        vm.$phraseInputString <~> tfPhraseInput.textProperty ~ subscriptions
        vm.$isSpeaking <~> swSpeak.isOnProperty ~ subscriptions
        vm.$onRepeat <~> swOnRepeat.isOnProperty ~ subscriptions
        vm.$moveForward <~> swMoveForward.isOnProperty ~ subscriptions
        vm.$onRepeatHidden ~> (svOnRepeat, \.isHidden) ~ subscriptions
        vm.$moveForwardHidden ~> (svMoveForward, \.isHidden) ~ subscriptions

        newTest(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.subscriptionTimer?.cancel()
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
            Task {
                await vm.newTest()
            }
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
