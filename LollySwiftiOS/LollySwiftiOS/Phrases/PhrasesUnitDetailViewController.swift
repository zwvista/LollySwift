//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown

class PhrasesUnitDetailViewController: UITableViewController, UITextFieldDelegate {
 
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    var vm: PhrasesUnitViewModel!
    var mPhrase: MUnitPhrase!
    var isAdd: Bool!
    let ddUnit = DropDown()
    let ddPart = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vm.vmSettings.arrUnits
        ddUnit.selectRow(mPhrase.UNIT - 1)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.mPhrase.UNIT = index + 1
            self.tfUnit.text = String(self.mPhrase.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vm.vmSettings.arrParts
        ddPart.selectRow(mPhrase.PART - 1)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.mPhrase.PART = index + 1
            self.tfPart.text = self.mPhrase.PARTSTR(arrParts: vmSettings.arrParts)
        }
        
        tfID.text = String(mPhrase.ID)
        tfUnit.text = String(mPhrase.UNIT)
        tfPart.text = mPhrase.PARTSTR(arrParts: vmSettings.arrParts)
        tfSeqNum.text = String(mPhrase.SEQNUM)
        tfPhrase.text = mPhrase.PHRASE
        tfTranslation.text = mPhrase.TRANSLATION
        isAdd = mPhrase.ID == 0
        (mPhrase.PHRASE.isEmpty ? tfPhrase : tfTranslation)?.becomeFirstResponder()
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

    func onDone() {
        mPhrase.SEQNUM = Int(tfSeqNum.text!)!
        mPhrase.PHRASE = tfPhrase.text!
        mPhrase.TRANSLATION = tfTranslation.text
        
        if isAdd {
            vm.arrPhrases.append(mPhrase)
            PhrasesUnitViewModel.create(item: mPhrase) { self.mPhrase.ID = $0 }
        } else {
            PhrasesUnitViewModel.update(item: mPhrase) {}
        }
    }
    
}
