//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown

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
    
    func startEdit(vm: WordsUnitViewModel, item: MUnitWord, phraseid: Int) {
        vmEdit = WordsUnitDetailViewModel(vm: vm, item: item, phraseid: phraseid) {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vmSettings.arrUnits.map(\.label)
        ddUnit.selectRow(itemEdit.indexUNIT.value)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexUNIT.accept(index)
            self.itemEdit.UNITSTR.accept(item)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vmSettings.arrParts.map(\.label)
        ddPart.selectRow(itemEdit.indexPART.value)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexPART.accept(index)
            self.itemEdit.PARTSTR.accept(item)
        }

        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.UNITSTR <~> tfUnit.rx.textInput
        _ = itemEdit.PARTSTR <~> tfPart.rx.textInput
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.textInput
        _ = itemEdit.WORDID ~> tfWordID.rx.text
        _ = itemEdit.WORD <~> tfWord.rx.textInput
        _ = itemEdit.NOTE <~> tfNote.rx.textInput
        _ = itemEdit.FAMIID ~> tfFamiID.rx.text
        _ = itemEdit.ACCURACY ~> tfAccuracy.rx.text
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
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
