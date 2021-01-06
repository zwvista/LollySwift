//
//  WordsUnitBatchAddViewController.swift
//  LollySwiftMac
//
//  Created by 趙　偉 on 2021/01/06.
//  Copyright © 2021 趙偉. All rights reserved.
//

import Cocoa

class WordsUnitBatchAddViewController: NSViewController {
    
    var vm: WordsUnitViewModel!
    var vmEdit: WordsUnitBatchAddViewModel!
    var complete: (() -> Void)?
    
    @IBOutlet weak var btnOK: NSButton!
    
    func startEdit(vm: WordsUnitViewModel, unit: Int, part: Int) {
        vmEdit = WordsUnitBatchAddViewModel(vm: vm, unit: unit, part: part)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
