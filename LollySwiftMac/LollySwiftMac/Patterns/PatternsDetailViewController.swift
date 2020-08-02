//
//  PatternsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@objcMembers
class PatternsDetailViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var vmDetail: PatternsDetailViewModel!
    var complete: (() -> Void)?
    var item: MPattern!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmDetail = PatternsDetailViewModel(vm: vm, item: item, complete: complete)
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (!vmDetail.isAdd ? tfPattern : tfNote).becomeFirstResponder()
        view.window?.title = vmDetail.isAdd ? "New Pattern" : item.PATTERN
    }
    
    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        vmDetail.onOK()
        dismiss(sender)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
