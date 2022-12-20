//
//  WordsLangDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

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
    var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        vmEdit = WordsLangDetailViewModel(vm: vm, item: item) {
            self.tableView.reloadData()
        }
        itemEdit.$ID ~> (tfID, \.text2) ~ subscriptions
        itemEdit.$WORD <~> tfWord.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        itemEdit.$FAMIID ~> (tfFamiID, \.text2) ~ subscriptions
        itemEdit.$ACCURACY ~> (tfAccuracy, \.text2) ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
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
