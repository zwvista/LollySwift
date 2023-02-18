//
//  LangBlogGroupsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LangBlogGroupsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfGroupName: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogGroupsDetailViewModel!
    var itemEdit: MLangBlogGroupEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.LANGBLOGGROUPNAME <~> tfGroupName.rx.text.orEmpty
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
        (vmEdit.isAdd ? tfID : tfGroupName).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Language Blog Group" : vmEdit.item.LANGBLOGGROUPNAME
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
