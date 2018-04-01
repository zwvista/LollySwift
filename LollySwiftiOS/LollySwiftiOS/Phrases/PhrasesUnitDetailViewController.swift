//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class PhrasesUnitDetailViewController: UITableViewController, UITextFieldDelegate {
    
    var vm: PhrasesUnitViewModel!
    var mPhrase: MUnitPhrase!
    var isAdd: Bool!

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        tfID.text = String(mPhrase.ID)
        tfUnit.text = String(mPhrase.UNIT)
        tfPart.text = mPhrase.PARTSTR(arrParts: vmSettings.arrParts)
        tfSeqNum.text = String(mPhrase.SEQNUM)
        tfPhrase.text = mPhrase.PHRASE
        tfTranslation.text = mPhrase.TRANSLATION
        isAdd = mPhrase.ID == 0
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === tfUnit {
            self.view.endEditing(true)
            ActionSheetStringPicker.show(withTitle: "Select Unit", rows: vmSettings.arrUnits, initialSelection: mPhrase.UNIT - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                self.mPhrase.UNIT = selectedIndex + 1
                self.tfUnit.text = String(self.mPhrase.UNIT)
            }, cancel: nil, origin: tfUnit)
            return false
        } else if textField === tfPart {
            self.view.endEditing(true)
            ActionSheetStringPicker.show(withTitle: "Select Part", rows: vmSettings.arrParts, initialSelection: mPhrase.PART - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                self.mPhrase.PART = selectedIndex + 1
                self.tfPart.text = self.mPhrase.PARTSTR(arrParts: vmSettings.arrParts)
            }, cancel: nil, origin: tfPart)
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
            PhrasesUnitViewModel.create(m: MUnitPhraseEdit(m: mPhrase)) { self.mPhrase.ID = $0 }
        } else {
            PhrasesUnitViewModel.update(mPhrase.ID, m: MUnitPhraseEdit(m: mPhrase)) {}
        }
    }
    
}
