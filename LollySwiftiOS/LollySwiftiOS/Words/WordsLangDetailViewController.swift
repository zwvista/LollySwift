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

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vm: WordsLangViewModel!
    var item: MLangWord!
    var vmEdit: WordsLangDetailViewModel!
    var itemEdit: MLangWordEdit { vmEdit.itemEdit }

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = WordsLangDetailViewModel(vm: vm, item: item)
        tfID.text = itemEdit.ID
        _ = itemEdit.WORD <~> tfWord.rx.textInput
        _ = itemEdit.NOTE <~> tfNote.rx.textInput
        tfFamiID.text = itemEdit.FAMIID
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
