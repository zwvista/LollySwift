//
//  WordsUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class WordsUnitDetailViewController: NSViewController {

    var vm: WordsUnitViewModel!
    var complete: (() -> Void)?
    var item: MUnitWord!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfWordID: NSTextField!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfWord: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfLevel: NSTextField!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: item.UNIT - 1)
        pubPart.selectItem(at: item.PART - 1)
        isAdd = item.ID == 0
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
        view.window?.title = isAdd ? "New Word" : item.WORD
    }

    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        item.UNIT = pubUnit.indexOfSelectedItem + 1
        item.PART = pubPart.indexOfSelectedItem + 1
        item.WORD = vm.vmSettings.autoCorrectInput(text: item.WORD)
        if isAdd {
            vm.arrWords.append(item)
            WordsUnitViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            WordsUnitViewModel.update(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
}
