//
//  PatternsWebPageEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit

class PatternsWebPageEditViewController: UITableViewController {

    var vm: PatternsViewModel!
    var vmEdit: PatternsWebPageEditViewModel!
    var itemEdit: MPatternWebPageEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var item: MPatternWebPage!

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPatternID: UITextField!
    @IBOutlet weak var tfPattern: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWebPageID: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!
    @IBOutlet weak var btnNew: UIButton!
    @IBOutlet weak var btnExisting: UIButton!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    func startEdit(item: MPatternWebPage) {
        vmEdit = PatternsWebPageEditViewModel(item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PATTERNID <~> tfPatternID.rx.textInput
        _ = itemEdit.PATTERN <~> tfPattern.rx.textInput
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.textInput
        _ = itemEdit.WEBPAGEID ~> tfWebPageID.rx.text.orEmpty
        _ = itemEdit.TITLE <~> tfTitle.rx.textInput
        _ = itemEdit.URL <~> tfURL.rx.textInput
        btnNew.isEnabled = vmEdit.isAddWebPage
        btnExisting.isEnabled = vmEdit.isAddWebPage
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        tfTitle.becomeFirstResponder()
    }
    
    @IBAction func newWebPage(_ sender: AnyObject) {
        itemEdit.WEBPAGEID.accept("0")
        itemEdit.TITLE.accept("")
        itemEdit.URL.accept("")
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? WebPageSelectViewController, let item = controller.vmWebPage.selectedWebPage {
            itemEdit.WEBPAGEID.accept(item.ID.toString)
            itemEdit.TITLE.accept(item.TITLE)
            itemEdit.URL.accept(item.URL)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
