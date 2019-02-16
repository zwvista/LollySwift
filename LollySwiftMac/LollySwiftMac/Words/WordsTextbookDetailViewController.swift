//
//  WordsTextbookDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class WordsTextbookDetailViewController: NSViewController {

    var vm: WordsTextbookViewModel!
    var complete: (() -> Void)?
    var item: MTextbookWord!

    @IBOutlet weak var pubTextbook: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfWord: NSTextField!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubTextbook.selectItem(at: item.UNIT - 1)
        pubPart.selectItem(at: item.PART - 1)
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        tfWord.becomeFirstResponder()
        view.window?.title = item.WORD
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.UNIT = pubTextbook.indexOfSelectedItem + 1
        item.PART = pubPart.indexOfSelectedItem + 1
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        WordsTextbookViewModel.update(item: item).subscribe {
            self.complete?()
        }.disposed(by: disposeBag)
        dismiss(self)
    }
}
