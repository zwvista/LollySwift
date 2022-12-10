//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import Combine

class WordsUnitDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWordID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!
    @IBOutlet weak var btnDone: UIBarButtonItem!
    
    var vmEdit: WordsUnitDetailViewModel!
    var item: MUnitWord { vmEdit.item }
    var itemEdit: MUnitWordEdit { vmEdit.itemEdit }
    let ddUnit = DropDown()
    let ddPart = DropDown()
    var subscriptions = Set<AnyCancellable>()

    func startEdit(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int) {
        vmEdit = WordsUnitDetailViewModel(vm: vm, item: item, phraseid: phraseid) {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vmSettings.arrUnits.map(\.label)
        ddUnit.selectRow(itemEdit.indexUNIT)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexUNIT = index
            self.itemEdit.UNITSTR = item
        }

        ddPart.anchorView = tfPart
        ddPart.dataSource = vmSettings.arrParts.map(\.label)
        ddPart.selectRow(itemEdit.indexPART)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexPART = index
            self.itemEdit.PARTSTR = item
        }

        itemEdit.$ID ~> (tfID, \.text2) ~ subscriptions
        itemEdit.$UNITSTR <~> tfUnit.textProperty ~ subscriptions
        itemEdit.$PARTSTR <~> tfPart.textProperty ~ subscriptions
        itemEdit.$SEQNUM <~> tfSeqNum.textProperty ~ subscriptions
        itemEdit.$WORDID ~> (tfWordID, \.text2) ~ subscriptions
        itemEdit.$WORD <~> tfWord.textProperty ~ subscriptions
        itemEdit.$NOTE <~> tfNote.textProperty ~ subscriptions
        itemEdit.$FAMIID ~> (tfFamiID, \.text2) ~ subscriptions
        itemEdit.$ACCURACY ~> (tfAccuracy, \.text2) ~ subscriptions
        vmEdit.$isOKEnabled ~> (btnDone, \.isEnabled) ~ subscriptions
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (vmEdit.isAdd ? tfWord : tfNote).becomeFirstResponder()
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
