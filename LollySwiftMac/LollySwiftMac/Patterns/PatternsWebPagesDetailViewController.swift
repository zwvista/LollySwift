//
//  PatternsWebPagesDetailViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import Combine

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
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = PatternsWebPagesDetailViewModel(item: item)
        itemEdit.$ID ~> (tfID, \.stringValue) ~ subscriptions
        itemEdit.$PATTERNID ~> (tfPatternID, \.stringValue) ~ subscriptions
        itemEdit.$PATTERN ~> (tfPattern, \.stringValue) ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        itemEdit.$WEBPAGEID ~> (tfWebPageID, \.stringValue) ~ subscriptions
        itemEdit.$TITLE <~> tfTitle.textProperty ~ subscriptions
        itemEdit.$URL <~> tfURL.textProperty ~ subscriptions
        btnNew.isEnabled = vmEdit.isAddWebPage
        btnExisting.isEnabled = vmEdit.isAddWebPage
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
        tfTitle.becomeFirstResponder()
        view.window?.title = vmEdit.isAddPatternWebPage ? "New Pattern Web Page" : item.TITLE
    }

    @IBAction func newWebPageID(_ sender: Any) {
        itemEdit.WEBPAGEID = "0"
    }
    
    @IBAction func existingWebPageID(_ sender: Any) {
        let webPageVC = self.storyboard!.instantiateController(withIdentifier: "WebPageSelectViewController") as! WebPageSelectViewController
        webPageVC.vm = vm
        webPageVC.complete = {
            let o = webPageVC.vmWebPage.selectedWebPage!
            self.itemEdit.WEBPAGEID = String(o.ID)
            self.itemEdit.TITLE = o.TITLE
            self.itemEdit.URL = o.URL
        }
        self.presentAsModalWindow(webPageVC)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
