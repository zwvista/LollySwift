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

    var vm: PatternsViewModel!
    var item: MPattern!
    var vmEdit: PatternsDetailViewModel!
    var itemEdit: MPatternEdit { vmEdit.itemEdit }
    var subscriptions = Set<AnyCancellable>()

    func startEdit(vm: PatternsViewModel, item: MPattern) {
        vmEdit = PatternsDetailViewModel(vm: vm, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        itemEdit.$ID ~> (tfID, \.text2) ~ subscriptions
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
