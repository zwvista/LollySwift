//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class WordsUnitDetailViewController: UITableViewController, UITextFieldDelegate {
    
    var vm: WordsUnitViewModel!    
    var mWord: MUnitWord!
    var isAdd: Bool!

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tfID.text = String(mWord.ID)
        tfUnit.text = String(mWord.UNIT)
        tfPart.text = mWord.PARTSTR(arrParts: vmSettings.arrParts)
        tfSeqNum.text = String(mWord.SEQNUM)
        tfWord.text = mWord.WORD
        tfNote.text = mWord.NOTE
        isAdd = mWord.ID == 0
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === tfUnit {
            self.view.endEditing(true)
            ActionSheetStringPicker.show(withTitle: "Select Unit", rows: vmSettings.arrUnits, initialSelection: mWord.UNIT - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                self.mWord.UNIT = selectedIndex + 1
                self.tfUnit.text = String(self.mWord.UNIT)
            }, cancel: nil, origin: tfUnit)
            return false
        } else if textField === tfPart {
            self.view.endEditing(true)
            ActionSheetStringPicker.show(withTitle: "Select Part", rows: vmSettings.arrParts, initialSelection: mWord.PART - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                self.mWord.PART = selectedIndex + 1
                self.tfPart.text = self.mWord.PARTSTR(arrParts: vmSettings.arrParts)
            }, cancel: nil, origin: tfPart)
            return false
        } else {
            return true
        }
    }
    
    func onDone() {
        mWord.SEQNUM = Int(tfSeqNum.text!)!
        mWord.WORD = tfWord.text ?? ""
        mWord.NOTE = tfNote.text ?? ""
        
        if isAdd {
            vm.arrWords.append(mWord)
            WordsUnitViewModel.create(m: MUnitWordEdit(m: mWord)) { self.mWord.ID = $0 }
        } else {
            WordsUnitViewModel.update(mWord.ID, m: MUnitWordEdit(m: mWord)) {}
        }
    }
    
}
