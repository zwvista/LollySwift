//
//  OnlineTextbooksDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa

@objcMembers
class OnlineTextbooksDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfOnlineTextbook: NSTextField!
    @IBOutlet weak var tfUnit: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!

    var complete: (() -> Void)?
    var item: MOnlineTextbook!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.integerValue = item.ID
        tfOnlineTextbook.stringValue = item.TEXTBOOKNAME
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
