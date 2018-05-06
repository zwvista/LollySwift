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
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    
    var vm: WordsUnitViewModel!
    var mWord: MUnitWord!
    var isAdd: Bool!
    let ddUnit = DropDown()
    let ddPart = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vm.vmSettings.arrUnits
        ddUnit.selectRow(mWord.UNIT - 1)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.mWord.UNIT = index + 1
            self.tfUnit.text = String(self.mWord.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vm.vmSettings.arrParts
        ddPart.selectRow(mWord.PART - 1)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.mWord.PART = index + 1
            self.tfPart.text = self.mWord.PARTSTR(arrParts: vmSettings.arrParts)
        }

        tfID.text = String(mWord.ID)
        tfUnit.text = String(mWord.UNIT)
        tfPart.text = mWord.PARTSTR(arrParts: vmSettings.arrParts)
        tfSeqNum.text = String(mWord.SEQNUM)
        tfWord.text = mWord.WORD
        tfNote.text = mWord.NOTE
        isAdd = mWord.ID == 0
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (mWord.WORD.isEmpty ? tfWord : tfNote)?.becomeFirstResponder()
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
        mWord.SEQNUM = Int(tfSeqNum.text!)!
        mWord.WORD = tfWord.text ?? ""
        mWord.NOTE = tfNote.text
        
        if isAdd {
            vm.arrWords.append(mWord)
            WordsUnitViewModel.create(item: mWord).subscribe(onNext: { self.mWord.ID = $0 })
        } else {
            WordsUnitViewModel.update(item: mWord).subscribe()
        }
    }
    
}
