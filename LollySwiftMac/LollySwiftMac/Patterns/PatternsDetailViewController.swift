//
//  PatternsDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import Combine

@objcMembers
class PatternsDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfNote: NSTextField!
    @IBOutlet weak var tfTags: NSTextField!
    @IBOutlet weak var btnOK: NSButton!

    var complete: (() -> Void)?
    var vmEdit: PatternsDetailViewModel!
    var item: MPattern { vmEdit.item }
    var itemEdit: MPatternEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.stringValue = itemEdit.ID
        itemEdit.$PATTERN <~> tfPattern.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        itemEdit.$TAGS <~> tfTags.textProperty ~ subscriptions
        btnOK.tapPublisher.sink {
            Task {
                await self.vmEdit.onOK()
                self.complete?()
                self.dismiss(self.btnOK)
            }
        } ~ subscriptions
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        (!vmEdit.isAdd ? tfPattern : tfNote).becomeFirstResponder()
        view.window?.title = vmEdit.isAdd ? "New Pattern" : item.PATTERN
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
