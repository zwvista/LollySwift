//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PhrasesUnitDetailViewController: NSViewController {

    var vm: PhrasesUnitViewModel!
    var complete: (() -> Void)?
    var mPhrase: MUnitPhrase!
    var isAdd: Bool!

    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfPhrase: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: mPhrase.UNIT - 1)
        pubPart.selectItem(at: mPhrase.PART - 1)
        // not working because this is a view?
        tfPhrase.becomeFirstResponder()
        isAdd = mPhrase.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        mPhrase.UNIT = pubUnit.indexOfSelectedItem + 1
        mPhrase.PART = pubPart.indexOfSelectedItem + 1
        if isAdd {
            vm.arrPhrases.append(mPhrase)
            PhrasesUnitViewModel.create(item: mPhrase).subscribe(onNext: {
                self.mPhrase.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PhrasesUnitViewModel.update(item: mPhrase).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
