//
//  PatternsWebPagesDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift
import RxBinding

@objcMembers
class PatternsWebPagesDetailViewController: NSViewController {

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPatternID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfWebPageID: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var btnNew: NSButton!
    @IBOutlet weak var btnExisting: NSButton!
    @IBOutlet weak var btnOK: NSButton!

    var vm: PatternsViewModel!
    var vmEdit: PatternsWebPagesDetailViewModel!
    var itemEdit: MPatternWebPageEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var item: MPatternWebPage!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PatternsWebPagesDetailViewModel(item: item)
        tfID.stringValue = itemEdit.ID
        tfPatternID.stringValue = itemEdit.PATTERNID
        tfPattern.stringValue = itemEdit.PATTERN
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.text.orEmpty
        _ = itemEdit.WEBPAGEID ~> tfWebPageID.rx.text.orEmpty
        _ = itemEdit.TITLE <~> tfTitle.rx.text.orEmpty
        _ = itemEdit.URL <~> tfURL.rx.text.orEmpty
        btnNew.isEnabled = vmEdit.isAddWebPage
        btnExisting.isEnabled = vmEdit.isAddWebPage
        btnOK.rx.tap.flatMap { [unowned self] in
            vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            complete?()
            dismiss(btnOK)
        } ~ rx.disposeBag
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        tfTitle.becomeFirstResponder()
        view.window?.title = vmEdit.isAddPatternWebPage ? "New Pattern Web Page" : item.TITLE
    }

    @IBAction func newWebPageID(_ sender: Any) {
        itemEdit.WEBPAGEID.accept("0")
    }

    @IBAction func existingWebPageID(_ sender: Any) {
        let webPageVC = storyboard!.instantiateController(withIdentifier: "WebPageSelectViewController") as! WebPageSelectViewController
        webPageVC.vm = vm
        webPageVC.complete = { [unowned self] in
            let o = webPageVC.vmWebPage.selectedWebPage!
            itemEdit.WEBPAGEID.accept(String(o.ID))
            itemEdit.TITLE.accept(o.TITLE)
            itemEdit.URL.accept(o.URL)
        }
        presentAsModalWindow(webPageVC)
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }

}
