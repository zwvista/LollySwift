//
//  PhrasesLangDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PhrasesLangDetailViewController: NSViewController {

    var vm: PhrasesLangViewModel!
    var complete: (() -> Void)?
    var mPhrase: MLangPhrase!
    var isAdd: Bool!

    @IBOutlet weak var tfPhrase: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // not working because this is a view?
        tfPhrase.becomeFirstResponder()
        isAdd = mPhrase.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        mPhrase.PHRASE = vm.vmSettings.autoCorrectInput(text: mPhrase.PHRASE)
        if isAdd {
            vm.arrPhrases.append(mPhrase)
            PhrasesLangViewModel.create(item: mPhrase).subscribe(onNext: {
                self.mPhrase.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PhrasesLangViewModel.update(item: mPhrase).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
