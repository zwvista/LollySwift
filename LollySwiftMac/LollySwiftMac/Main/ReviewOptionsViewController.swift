//
//  ReviewOptionsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class ReviewOptionsViewController: NSViewController {

    @objc var options = MReviewOptions()
    var complete: (() -> Void)?

    @IBOutlet weak var pubMode: NSPopUpButton!
    @IBOutlet weak var scOrder: NSSegmentedControl!
    @IBOutlet weak var scLevel: NSSegmentedControl!
    @IBOutlet weak var lblLevel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pubMode.selectItem(at: options.mode)
        scOrder.selectedSegment = options.shuffled ? 1 : 0
        if let b = options.levelge0only {
            scLevel.selectedSegment = b ? 1 : 0
        } else {
            lblLevel.isHidden = true
            scLevel.isHidden = true
        }
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        self.commitEditing()
        options.mode = pubMode.indexOfSelectedItem
        options.shuffled = scOrder.selectedSegment == 1
        options.levelge0only = scLevel.selectedSegment == 1
        complete?()
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
