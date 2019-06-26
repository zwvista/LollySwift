//
//  ReviewOptionsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class ReviewOptionsViewController: NSViewController {

    var mode = 0
    @objc var interval = 3
    var shuffled = false
    var levelge0only: Bool?
    var complete: (() -> Void)?

    @IBOutlet weak var pubMode: NSPopUpButton!
    @IBOutlet weak var scOrder: NSSegmentedControl!
    @IBOutlet weak var scLevel: NSSegmentedControl!
    @IBOutlet weak var lblLevel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pubMode.selectItem(at: mode)
        scOrder.selectedSegment = shuffled ? 1 : 0
        if let b = levelge0only {
            scLevel.selectedSegment = b ? 1 : 0
        } else {
            lblLevel.isHidden = true
            scLevel.isHidden = true
        }
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        self.commitEditing()
        mode = pubMode.indexOfSelectedItem
        shuffled = scOrder.selectedSegment == 1
        levelge0only = scLevel.selectedSegment == 1
        complete?()
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
