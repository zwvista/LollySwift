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
    var item: MTextbookPhrase!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfTextbookName: NSTextField!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfPhraseID: NSTextField!
    @IBOutlet weak var tfPhrase: NSTextField!
    @IBOutlet weak var tfTranslation: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: item.UNIT - 1)
        pubPart.selectItem(at: item.PART - 1)
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation).becomeFirstResponder()
        view.window?.title = item.PHRASE
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.UNIT = pubUnit.indexOfSelectedItem + 1
        item.PART = pubPart.indexOfSelectedItem + 1
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: item.PHRASE)
        PhrasesTextbookViewModel.update(item: item).subscribe {
            self.complete?()
        }.disposed(by: disposeBag)
        dismiss(self)
    }
}