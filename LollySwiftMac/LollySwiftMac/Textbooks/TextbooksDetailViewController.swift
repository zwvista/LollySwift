//
//  TextbooksDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class TextbooksDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfTextbookName: NSTextField!
    @IBOutlet weak var tvUnits: NSTextView!
    @IBOutlet weak var tfParts: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: TextbooksDetailViewModel!
    var itemEdit: MTextbookEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.TEXTBOOKNAME <~> tfTextbookName.rx.text.orEmpty
        _ = itemEdit.UNITS <~> tvUnits.rx.string
        _ = itemEdit.PARTS ~> tfParts.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnOK.rx.isEnabled

        btnOK.rx.tap.flatMap { [unowned self] in
            commitEditing()
            return vmEdit.onOK()
        }.subscribe{ [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        (vmEdit.isAdd ? tfID : tfTextbookName).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Textbook" : vmEdit.item.TEXTBOOKNAME
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
