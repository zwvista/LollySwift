//
//  WordsUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa

class WordsUnitDetailViewController: NSViewController {

    @objc
    var vm: WordsUnitViewModel!
    var complete: (() -> Void)?
    @objc
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
        mWord.UNIT = pubUnit.indexOfSelectedItem + 1
        mWord.PART = pubPart.indexOfSelectedItem + 1
        if isAdd {
            vm.arrWords.append(mWord)
            WordsUnitViewModel.create(m: MUnitWordEdit(m: mWord)) { self.mWord.ID = $0 }
        } else {
            WordsUnitViewModel.update(mWord.ID, m: MUnitWordEdit(m: mWord)) {}
        }
        dismissViewController(self)
    }
}
