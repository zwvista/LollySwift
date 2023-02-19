//
//  LangBlogsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LangBlogsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfGroupName: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogsDetailViewModel!
    var itemEdit: MLangBlogEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        tfGroupName.stringValue = itemEdit.GROUPNAME
        _ = itemEdit.TITLE <~> tfTitle.rx.text.orEmpty
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
        view.window?.title = vmEdit.isAdd ? "New Language Blog" : vmEdit.item.TITLE
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
