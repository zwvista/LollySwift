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
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: PatternsDetailViewModel!
    var item: MPattern { vmEdit.item }
    var itemEdit: MPatternEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        _ = itemEdit.PATTERN <~> tfPattern.rx.text.orEmpty
        _ = itemEdit.TAGS <~> tfTags.rx.text.orEmpty
        _ = itemEdit.TITLE <~> tfTitle.rx.text.orEmpty
        _ = itemEdit.URL <~> tfURL.rx.text.orEmpty
        btnOK.rx.tap.flatMap { [unowned self] in
            vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (!vmEdit.isAdd ? tfPattern : tfTags).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Pattern" : item.PATTERN
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
