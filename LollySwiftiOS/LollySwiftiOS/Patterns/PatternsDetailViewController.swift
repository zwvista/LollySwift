//
//  PatternsDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class PatternsDetailViewController: UITableViewController {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPattern: UITextField!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var tfTitle: UITextField!
    @IBOutlet weak var tfURL: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vmEdit: PatternsDetailViewModel!
    var item: MPattern { vmEdit.item }
    var itemEdit: MPatternEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = itemEdit.ID
        _ = itemEdit.PATTERN <~> tfPattern.rx.textInput
        _ = itemEdit.TAGS <~> tfTags.rx.textInput
        _ = itemEdit.TITLE <~> tfTitle.rx.textInput
        _ = itemEdit.URL <~> tfURL.rx.textInput
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (vmEdit.isAdd ? tfPattern : tfTags).becomeFirstResponder()
    }

    deinit {
        print("DEBUG: \(className) deinit")
    }
}
