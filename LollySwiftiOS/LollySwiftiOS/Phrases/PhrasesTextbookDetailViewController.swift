//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import Combine

class PhrasesTextbookDetailViewController: UITableViewController {

    @IBOutlet weak var tfTextbookName: UITextField!
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhraseID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!

    var vmEdit: PhrasesUnitDetailViewModel!
    var item: MUnitPhrase { vmEdit.item }
    var itemEdit: MUnitPhraseEdit { vmEdit.itemEdit }
    let ddUnit = DropDown()
    let ddPart = DropDown()
    var subscriptions = Set<AnyCancellable>()

    func startEdit(vm: PhrasesUnitViewModel, item: MUnitPhrase, wordid: Int) {
        vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: wordid) {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = item.textbook.arrUnits.map(\.label)
        ddUnit.selectRow(itemEdit.indexUNIT)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexUNIT = index
            self.itemEdit.UNITSTR = item
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = item.textbook.arrParts.map(\.label)
        ddPart.selectRow(itemEdit.indexPART)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexPART = index
            self.itemEdit.PARTSTR = item
        }
        
        itemEdit.$ID ~> (tfID, \.text2) ~ subscriptions
        itemEdit.$TEXTBOOKNAME ~> (tfTextbookName, \.text2) ~ subscriptions
        itemEdit.$UNITSTR <~> tfUnit.textProperty ~ subscriptions
        itemEdit.$PARTSTR <~> tfPart.textProperty ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        itemEdit.$PHRASEID ~> (tfPhraseID, \.text2) ~ subscriptions
        itemEdit.$PHRASE <~> tfPhrase.textProperty ~ subscriptions
        itemEdit.$TRANSLATION <~> tfTranslation.textProperty ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation).becomeFirstResponder()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === tfUnit {
            self.view.endEditing(true)
            ddUnit.show()
            return false
        } else if textField === tfPart {
            self.view.endEditing(true)
            ddPart.show()
            return false
        } else {
            return true
        }
    }

    deinit {
        print("DEBUG: \(self.className) deinit")
    }
}
