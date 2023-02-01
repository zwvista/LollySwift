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

    var vm: TextbooksViewModel!
    var complete: (() -> Void)?
    @objc var item: MTextbook!
    var isAdd: Bool!
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.title = item.TEXTBOOKNAME
        tfID.isEnabled = isAdd
        tfLang.stringValue = vm.vmSettings.selectedLang.LANGNAME
        (isAdd ? tfID : tfTextbookName).becomeFirstResponder()
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        commitEditing()
        Task {
            if isAdd {
                _ = await TextbooksViewModel.create(item: item)
            } else {
                await TextbooksViewModel.update(item: item)
            }
            complete?()
            dismiss(sender)
        }
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
