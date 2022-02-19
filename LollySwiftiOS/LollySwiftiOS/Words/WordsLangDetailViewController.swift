//
//  WordsLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import RxBinding

class WordsLangDetailViewController: UITableViewController {
    
    var vm: WordsLangViewModel!
    var item: MLangWord!
    var vmEdit: WordsLangDetailViewModel!
    var itemEdit: MLangWordEdit { vmEdit.itemEdit }

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = WordsLangDetailViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.WORD <~> tfWord.rx.text.orEmpty
        _ = itemEdit.NOTE <~> tfNote.rx.text.orEmpty
        _ = itemEdit.FAMIID ~> tfFamiID.rx.text.orEmpty
        _ = itemEdit.ACCURACY ~> tfAccuracy.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
    }
    
    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
