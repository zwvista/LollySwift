//
//  LangBlogPostsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import Combine

class LangBlogPostsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfUrl: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogsDetailViewModel!
    var itemEdit: MLangBlogPostEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.$TITLE <~> tfTitle.textProperty ~ subscriptions
        _ = itemEdit.$URL <~> tfUrl.textProperty ~ subscriptions
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
        view.window?.title = vmEdit.isAdd ? "New Language Blog Post" : vmEdit.item.TITLE
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
