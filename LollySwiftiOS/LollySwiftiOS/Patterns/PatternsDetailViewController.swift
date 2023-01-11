//
//  PatternsDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class PatternsDetailViewController: UITableViewController {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPattern: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vmEdit: PatternsDetailViewModel!
    var item: MPattern { vmEdit.item }
    var itemEdit: MPatternEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = itemEdit.ID
        itemEdit.$PATTERN <~> tfPattern.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        itemEdit.$TAGS <~> tfTags.textProperty ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (vmEdit.isAdd ? tfPattern : tfNote).becomeFirstResponder()
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
