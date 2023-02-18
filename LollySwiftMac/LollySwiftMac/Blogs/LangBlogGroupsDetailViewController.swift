//
//  LangBlogGroupsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/18.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import Combine

class LangBlogGroupsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfGroupName: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogGroupsDetailViewModel!
    var itemEdit: MLangBlogGroupEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.$LANGBLOGGROUPNAME ~> (tfGroupName, \.stringValue) ~ subscriptions
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
        view.window?.title = vmEdit.isAdd ? "New Language Blog Group" : vmEdit.item.LANGBLOGGROUPNAME
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
