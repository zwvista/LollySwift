//
//  ReviewOptionsViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2019/06/26.
//  Copyright © 2019 趙偉. All rights reserved.
//

import Cocoa

class ReviewOptionsViewController: NSViewController {

    @objc var vm = ReviewOptionsViewModel()
    var complete: (() -> Void)?

    @IBOutlet weak var pubMode: NSPopUpButton!
    @IBOutlet weak var scOrder: NSSegmentedControl!
    @IBOutlet weak var scLevel: NSSegmentedControl!
    @IBOutlet weak var lblLevel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pubMode.selectItem(at: vm.mode)
        scOrder.selectedSegment = vm.shuffled ? 1 : 0
        if let b = vm.levelge0only {
            scLevel.selectedSegment = b ? 1 : 0
        } else {
            lblLevel.isHidden = true
            scLevel.isHidden = true
        }
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        self.commitEditing()
        vm.mode = pubMode.indexOfSelectedItem
        vm.shuffled = scOrder.selectedSegment == 1
        vm.levelge0only = scLevel.selectedSegment == 1
        complete?()
        dismiss(self)
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
