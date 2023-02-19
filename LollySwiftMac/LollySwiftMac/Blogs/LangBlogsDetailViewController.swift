//
//  LangBlogsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import Combine

class LangBlogsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfGroupName: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogsDetailViewModel!
    var itemEdit: MLangBlogEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        tfGroupName.stringValue = itemEdit.GROUPNAME
        _ = itemEdit.$TITLE <~> tfTitle.textProperty ~ subscriptions
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
        (vmEdit.isAdd ? tfID : tfGroupName).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Language Blog" : vmEdit.item.TITLE
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
