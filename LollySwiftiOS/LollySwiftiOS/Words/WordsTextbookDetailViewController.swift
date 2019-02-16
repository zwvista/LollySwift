//
//  WordsTextbookDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

class WordsTextbookDetailViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfTextbookName: UITextField!
    @IBOutlet weak var tfEntryID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWordID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfLevel: UITextField!
    
    var vm: WordsTextbookViewModel!
    var item: MTextbookWord!
    let ddUnit = DropDown()
    let ddPart = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = item.arrUnits
        ddUnit.selectRow(item.UNIT - 1)
        ddUnit.selectionAction = { (index: Int, item: String) in
            self.item.UNIT = index + 1
            self.tfUnit.text = String(self.item.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = item.arrParts
        ddPart.selectRow(item.PART - 1)
        ddPart.selectionAction = { (index: Int, item: String) in
            self.item.PART = index + 1
            self.tfPart.text = self.item.PARTSTR
        }
        tfTextbookName.text = item.TEXTBOOKNAME
        tfEntryID.text = String(item.ENTRYID)
        tfUnit.text = String(item.UNIT)
        tfPart.text = item.PARTSTR
        tfSeqNum.text = String(item.SEQNUM)
        tfWordID.text = String(item.WORDID)
        tfWord.text = item.WORD
        tfNote.text = item.NOTE
        tfFamiID.text = String(item.FAMIID)
        tfLevel.text = String(item.LEVEL)
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.WORD.isEmpty ? tfWord : tfNote).becomeFirstResponder()
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
        item.SEQNUM = Int(tfSeqNum.text!)!
        item.WORD = vm.vmSettings.autoCorrectInput(text: tfWord.text ?? "")
        item.NOTE = tfNote.text
        item.LEVEL = Int(tfLevel.text!)!
    }
    
}
