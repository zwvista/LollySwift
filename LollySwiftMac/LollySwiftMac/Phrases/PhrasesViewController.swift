//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class PhrasesViewController: NSViewController, LollyProtocol, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    func settingsChanged() {
    }
}

class PhrasesWindowController: NSWindowController, NSTextFieldDelegate {
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
}

