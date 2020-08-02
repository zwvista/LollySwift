//
//  PatternsEditViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import NSObject_Rx

@objcMembers
class PatternsEditViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var vmEdit: PatternsEditViewModel!
    var complete: (() -> Void)?
    var item: MPattern!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PatternsEditViewModel(vm: vm, item: item, complete: complete)
        vmEdit.itemEdit.ID ~> tfID.rx.text.orEmpty ~ rx.disposeBag
        vmEdit.itemEdit.PATTERN <~> tfPattern.rx.text.orEmpty ~ rx.disposeBag
        vmEdit.itemEdit.NOTE <~> tfNote.rx.text ~ rx.disposeBag
        vmEdit.itemEdit.TAGS <~> tfTags.rx.text ~ rx.disposeBag
        btnOK.rx.tap.subscribe { [unowned self] _ in
            self.vmEdit.onOK()
            self.dismiss(self.btnOK)
        } ~ rx.disposeBag
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (!vmEdit.isAdd ? tfPattern : tfNote).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Pattern" : item.PATTERN
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
