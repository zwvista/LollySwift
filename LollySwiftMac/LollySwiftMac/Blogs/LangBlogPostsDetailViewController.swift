//
//  LangBlogPostsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2023/02/19.
//  Copyright © 2023 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

class LangBlogPostsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfLang: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfUrl: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: LangBlogsDetailViewModel!
    var itemEdit: MLangBlogPostEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        tfLang.stringValue = vmEdit.vm.vmSettings.selectedLang.LANGNAME
        _ = itemEdit.TITLE <~> tfTitle.rx.text.orEmpty
        _ = itemEdit.URL <~> tfUrl.rx.text.orEmpty
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
        view.window?.title = vmEdit.isAdd ? "New Language Blog Post" : vmEdit.item.TITLE
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
