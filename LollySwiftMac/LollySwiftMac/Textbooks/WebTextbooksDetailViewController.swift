//
//  WebTextbooksDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

@objcMembers
class WebTextbooksDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfWebTextbook: NSTextField!
    @IBOutlet weak var tfUnit: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var item: MWebTextbook!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.integerValue = item.ID
        tfWebTextbook.stringValue = item.TEXTBOOKNAME
        tfUnit.integerValue = item.UNIT
        tfTitle.stringValue = item.TITLE
        tfURL.stringValue = item.URL
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = item.TITLE
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
