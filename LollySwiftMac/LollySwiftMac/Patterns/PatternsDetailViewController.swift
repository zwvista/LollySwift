//
//  PatternsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PatternsDetailViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var vmEdit: PatternsDetailViewModel!
    var itemEdit: MPatternEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var item: MPattern!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!
    @IBOutlet weak var btnOK: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PatternsDetailViewModel(vm: vm, item: item)
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PATTERN <~> tfPattern.rx.text.orEmpty
        _ = itemEdit.NOTE <~> tfNote.rx.text.orEmpty
        _ = itemEdit.TAGS <~> tfTags.rx.text.orEmpty
        btnOK.rx.tap.take(1).flatMap { [unowned self] _ in
            self.vmEdit.onOK()
        }.subscribe(onCompleted: { [unowned self] in
            self.complete?()
            self.dismiss(self.btnOK)
        }) ~ rx.disposeBag
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
