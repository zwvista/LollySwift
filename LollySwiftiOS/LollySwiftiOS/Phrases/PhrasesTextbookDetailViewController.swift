//
//  PhrasesTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

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
    
    func startEdit(vm: PhrasesUnitViewModel, item: MUnitPhrase, wordid: Int) {
        vmEdit = PhrasesUnitDetailViewModel(vm: vm, item: item, wordid: wordid) {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = item.textbook.arrUnits.map(\.label)
        ddUnit.selectRow(itemEdit.indexUNIT.value)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexUNIT.accept(index)
            self.itemEdit.UNITSTR.accept(item)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = item.textbook.arrParts.map(\.label)
        ddPart.selectRow(itemEdit.indexPART.value)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.itemEdit.indexPART.accept(index)
            self.itemEdit.PARTSTR.accept(item)
        }
        
        _ = itemEdit.ID ~> tfID.rx.text.orEmpty
        _ = itemEdit.TEXTBOOKNAME ~> tfTextbookName.rx.text.orEmpty
        _ = itemEdit.UNITSTR <~> tfUnit.rx.text.orEmpty
        _ = itemEdit.PARTSTR <~> tfPart.rx.text.orEmpty
        _ = itemEdit.SEQNUM <~> tfSeqNum.rx.text.orEmpty
        _ = itemEdit.PHRASEID ~> tfPhraseID.rx.text.orEmpty
        _ = itemEdit.PHRASE <~> tfPhrase.rx.text.orEmpty
        _ = itemEdit.TRANSLATION <~> tfTranslation.rx.text.orEmpty
        _ = vmEdit.isOKEnabled ~> btnDone.rx.isEnabled
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
