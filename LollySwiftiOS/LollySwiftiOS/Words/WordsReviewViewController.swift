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
import RxBinding

class WordsReviewViewController: UIViewController, UITextFieldDelegate {
    var vm: WordsReviewViewModel!

    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblCorrect: UILabel!
    @IBOutlet weak var lblIncorrect: UILabel!
    @IBOutlet weak var lblAccuracy: UILabel!
    @IBOutlet weak var lblWordTarget: UILabel!
    @IBOutlet weak var lblNoteTarget: UILabel!
    @IBOutlet weak var tvTranslation: UITextView!
    @IBOutlet weak var tfWordInput: UITextField!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        vm = WordsReviewViewModel(settings: vmSettings, needCopy: false) { [unowned self] in
            self.tfWordInput.becomeFirstResponder()
            if self.vm.hasCurrent && self.vm.isSpeaking.value {
                AppDelegate.speak(string: self.vm.currentWord)
            }
        }
        
        _ = vm.indexString ~> lblIndex.rx.text
        _ = vm.indexHidden ~> lblIndex.rx.isHidden
        _ = vm.correctHidden ~> lblCorrect.rx.isHidden
        _ = vm.incorrectHidden ~> lblIncorrect.rx.isHidden
        _ = vm.accuracyString ~> lblAccuracy.rx.text
        _ = vm.accuracyHidden ~> lblAccuracy.rx.isHidden
        _ = vm.checkNextEnabled ~> btnCheckNext.rx.isEnabled
        _ = vm.checkNextTitle ~> btnCheckNext.rx.title(for: .normal)
        _ = vm.checkPrevEnabled ~> btnCheckPrev.rx.isEnabled
        _ = vm.checkPrevTitle ~> btnCheckPrev.rx.title(for: .normal)
        _ = vm.checkPrevHidden ~> btnCheckPrev.rx.isHidden
        _ = vm.wordTargetString ~> lblWordTarget.rx.text
        _ = vm.noteTargetString ~> lblNoteTarget.rx.text
        _ = vm.wordTargetHidden ~> lblWordTarget.rx.isHidden
        _ = vm.noteTargetHidden ~> lblNoteTarget.rx.isHidden
        _ = vm.translationString ~> tvTranslation.rx.text
        _ = vm.wordInputString <~> tfWordInput.rx.textInput
        _ = vm.isSpeaking <~> swSpeak.rx.isOn
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
        AppDelegate.speak(string: vm.currentWord)
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
