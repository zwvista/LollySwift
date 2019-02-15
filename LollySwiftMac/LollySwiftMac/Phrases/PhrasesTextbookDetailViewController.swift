//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PhrasesTextbookDetailViewController: NSViewController {

    var vm: PhrasesTextbookViewModel!
    var complete: (() -> Void)?
    var mPhrase: MTextbookPhrase!

    @IBOutlet weak var pubTextbook: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfPhrase: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubTextbook.selectItem(at: mPhrase.UNIT - 1)
        pubPart.selectItem(at: mPhrase.PART - 1)
        // not working because this is a view?
        tfPhrase.becomeFirstResponder()
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        mPhrase.UNIT = pubTextbook.indexOfSelectedItem + 1
        mPhrase.PART = pubPart.indexOfSelectedItem + 1
        mPhrase.PHRASE = vm.vmSettings.autoCorrectInput(text: mPhrase.PHRASE)
        PhrasesTextbookViewModel.update(item: mPhrase).subscribe {
            self.complete?()
        }.disposed(by: disposeBag)
        dismiss(self)
    }
}
