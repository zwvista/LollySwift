//
//  PatternsWebPagesDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import WebKit
import RxBinding

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

    func startEdit(item: MPatternWebPage) {
        vmEdit = PatternsWebPagesDetailViewModel(item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = itemEdit.ID
        tfPatternID.text = itemEdit.PATTERNID
        tfPattern.text = itemEdit.PATTERN
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
            itemEdit.WEBPAGEID.accept(String(item.ID))
            itemEdit.TITLE.accept(item.TITLE)
            itemEdit.URL.accept(item.URL)
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
