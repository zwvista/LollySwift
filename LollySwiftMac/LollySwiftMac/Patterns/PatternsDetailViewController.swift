//
//  PatternsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

@objcMembers
class PatternsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!

    var complete: (() -> Void)?
    var item: MPattern!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.integerValue = item.ID
        tfPattern.stringValue = item.PATTERN
        tfTags.stringValue = item.TAGS
        tfTitle.stringValue = item.TITLE
        tfURL.stringValue = item.URL
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = item.PATTERN
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
