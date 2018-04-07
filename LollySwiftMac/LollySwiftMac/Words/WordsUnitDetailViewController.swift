//
//  WordsUnitDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa

class WordsUnitDetailViewController: NSViewController {

    var vm: WordsUnitViewModel!
    var complete: (() -> Void)?
    @objc
    var mWord: MUnitWord!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
