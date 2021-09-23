//
//  PatternsWebPagesDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PatternsWebPagesDetailViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var vmEdit: PatternsWebPagesDetailViewModel!
    var itemEdit: MPatternWebPageEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var item: MPatternWebPage!

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

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PatternsWebPagesDetailViewModel(item: item)
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PATTERNID ~> tfPatternID.rx.text.orEmpty
        _ = itemEdit.PATTERN ~> tfPattern.rx.text.orEmpty
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.text.orEmpty
        _ = itemEdit.WEBPAGEID ~> tfWebPageID.rx.text.orEmpty
        _ = itemEdit.TITLE <~> tfTitle.rx.text.orEmpty
        _ = itemEdit.URL <~> tfURL.rx.text.orEmpty
        btnNew.isEnabled = vmEdit.isAddWebPage
        btnExisting.isEnabled = vmEdit.isAddWebPage
        btnOK.rx.tap.flatMap { [unowned self] _ in
            self.vmEdit.onOK()
        }.subscribe { [unowned self] _ in
            self.complete?()
            self.dismiss(self.btnOK)
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
        let webPageVC = self.storyboard!.instantiateController(withIdentifier: "WebPageSelectViewController") as! WebPageSelectViewController
        webPageVC.vm = vm
        webPageVC.complete = {
            let o = webPageVC.vmWebPage.selectedWebPage!
            self.itemEdit.WEBPAGEID.accept(String(o.ID))
            self.itemEdit.TITLE.accept(o.TITLE)
            self.itemEdit.URL.accept(o.URL)
        }
        self.presentAsModalWindow(webPageVC)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
