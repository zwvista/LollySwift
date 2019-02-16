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
    var item: MUnitPhrase!
    var isAdd: Bool!

    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfPhrase: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: item.UNIT - 1)
        pubPart.selectItem(at: item.PART - 1)
        // not working because this is a view?
        tfPhrase.becomeFirstResponder()
        isAdd = item.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.UNIT = pubUnit.indexOfSelectedItem + 1
        item.PART = pubPart.indexOfSelectedItem + 1
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        if isAdd {
            vm.arrPhrases.append(item)
            PhrasesUnitViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PhrasesUnitViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
