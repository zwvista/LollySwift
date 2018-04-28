//
//  WordsUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa

@objcMembers
class WordsUnitDetailViewController: NSViewController {

    var vm: WordsUnitViewModel!
    var complete: (() -> Void)?
    var mWord: MUnitWord!
    var isAdd: Bool!

    @IBOutlet weak var pubUnit: NSPopUpButton!
    @IBOutlet weak var pubPart: NSPopUpButton!
    @IBOutlet weak var tfWord: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        pubUnit.selectItem(at: mWord.UNIT - 1)
        pubPart.selectItem(at: mWord.PART - 1)
        // not working because this is a view?
        tfWord.becomeFirstResponder()
        isAdd = mWord.ID == 0
    }
    
    @IBAction func okClicked(_ sender: Any) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        mWord.UNIT = pubUnit.indexOfSelectedItem + 1
        mWord.PART = pubPart.indexOfSelectedItem + 1
        if isAdd {
            vm.arrWords.append(mWord)
            WordsUnitViewModel.create(m: mWord) { self.mWord.ID = $0; self.complete?() }
        } else {
            WordsUnitViewModel.update(m: mWord) { self.complete?() }
        }
        dismissViewController(self)
    }
}
