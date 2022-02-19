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
    
    var vm: PatternsViewModel!
    var item: MPattern!
    var vmEdit: PatternsDetailViewModel!
    var itemEdit: MPatternEdit { vmEdit.itemEdit }

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfPattern: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfTags: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    func startEdit(vm: PatternsViewModel, item: MPattern) {
        vmEdit = PatternsDetailViewModel(vm: vm, item: item)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.PATTERN <~> tfPattern.rx.text.orEmpty
        _ = itemEdit.NOTE <~> tfNote.rx.text.orEmpty
        _ = itemEdit.TAGS <~> tfTags.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
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
