//
//  PatternsWebPagesDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import Combine

class PatternsWebPagesDetailViewController: UITableViewController {

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

    var vm: PatternsViewModel!
    var vmEdit: PatternsWebPagesDetailViewModel!
    var itemEdit: MPatternWebPageEdit { vmEdit.itemEdit }
    var complete: (() -> Void)?
    var item: MPatternWebPage!
    var subscriptions = Set<AnyCancellable>()

    func startEdit(item: MPatternWebPage) {
        vmEdit = PatternsWebPagesDetailViewModel(item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = itemEdit.ID
        tfPatternID.text = itemEdit.PATTERNID
        tfPattern.text = itemEdit.PATTERN
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        itemEdit.$WEBPAGEID ~> (tfWebPageID, \.text2) ~ subscriptions
        itemEdit.$TITLE <~> tfTitle.textProperty ~ subscriptions
        itemEdit.$URL <~> tfURL.textProperty ~ subscriptions
        btnNew.isEnabled = vmEdit.isAddWebPage
        btnExisting.isEnabled = vmEdit.isAddWebPage
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        tfTitle.becomeFirstResponder()
    }

    @IBAction func newWebPage(_ sender: AnyObject) {
        itemEdit.WEBPAGEID = "0"
        itemEdit.TITLE = ""
        itemEdit.URL = ""
    }

    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        if let controller = segue.source as? WebPageSelectViewController, let item = controller.vmWebPage.selectedWebPage {
            itemEdit.WEBPAGEID = String(item.ID)
            itemEdit.TITLE = item.TITLE
            itemEdit.URL = item.URL
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
