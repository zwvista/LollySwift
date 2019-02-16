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
    var item: MLangPhrase!
    var isAdd: Bool!

    @IBOutlet weak var tfPhrase: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // not working because this is a view?
        tfPhrase.becomeFirstResponder()
        isAdd = item.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            PhrasesLangViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PhrasesLangViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
