//
//  TextbooksDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2018/04/07.
//  Copyright © 2018年 趙偉. All rights reserved.
//

import Cocoa
import Combine

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
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.$TEXTBOOKNAME ~> (tfTextbookName, \.stringValue) ~ subscriptions
        _ = itemEdit.$UNITS <~> tvUnits.textProperty ~ subscriptions
        _ = itemEdit.$PARTS ~> (tfParts, \.stringValue) ~ subscriptions
        _ = vmEdit.$isOKEnabled ~> (btnOK, \.isEnabled) ~ subscriptions

        btnOK.tapPublisher.sink { [unowned self] in
            commitEditing()
            Task {
                await vmEdit.onOK()
                complete?()
                dismiss(btnOK)
            }
        } ~ subscriptions
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
