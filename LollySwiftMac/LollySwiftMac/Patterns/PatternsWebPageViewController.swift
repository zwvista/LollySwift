//
//  PatternsWebPageViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2020/01/01.
//  Copyright © 2020 趙偉. All rights reserved.
//

import Cocoa
import RxSwift

@objcMembers
class PatternsWebPageViewController: NSViewController {
    
    var vm: PatternsViewModel!
    var complete: (() -> Void)?
    var item: MPatternWebPage!
    var isAdd: Bool!

    @IBOutlet weak var tfID: NSTextField!
    @IBOutlet weak var tfPatternID: NSTextField!
    @IBOutlet weak var tfPattern: NSTextField!
    @IBOutlet weak var tfSeqNum: NSTextField!
    @IBOutlet weak var tfWebPageID: NSTextField!
    @IBOutlet weak var tfTitle: NSTextField!
    @IBOutlet weak var tfURL: NSTextField!
    @IBOutlet weak var btnNew: NSButton!
    @IBOutlet weak var btnExisting: NSButton!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        isAdd = item.ID == 0
        btnNew.isEnabled = isAdd
        btnExisting.isEnabled = isAdd
    }
    
    override func viewDidAppear() {
        // https://stackoverflow.com/questions/24235815/cocoa-how-to-set-window-title-from-within-view-controller-in-swift
        tfTitle.becomeFirstResponder()
        view.window?.title = isAdd ? "New Page" : item.TITLE
    }

    @IBAction func okClicked(_ sender: AnyObject) {
        // https://stackoverflow.com/questions/1590204/cocoa-bindings-update-nsobjectcontroller-manually
        self.commitEditing()
        if isAdd {
            vm.arrWebPages.append(item)
            PatternsViewModel.createWebPage(item: item).subscribe(onNext: {
                self.item.ID = $0
                self.complete?()
            }).disposed(by: disposeBag)
        } else {
            PatternsViewModel.updateWebPage(item: item).subscribe {
                self.complete?()
            }.disposed(by: disposeBag)
        }
        dismiss(self)
    }
    @IBAction func newWebPageID(_ sender: Any) {
        tfWebPageID.stringValue = "0"
    }
    
    @IBAction func existingWebPageID(_ sender: Any) {
        let webPageVC = self.storyboard!.instantiateController(withIdentifier: "WebPageSelectViewController") as! WebPageSelectViewController
        webPageVC.vm = vm
        webPageVC.complete = {
            let o = webPageVC.vmWebPage.selectedWebPage!
            self.item.WEBPAGEID = o.ID
            self.item.TITLE = o.TITLE
            self.item.URL = o.URL
        }
        self.presentAsModalWindow(webPageVC)
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }

}
