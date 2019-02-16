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
    @IBOutlet weak var tfEntryID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhraseID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!
    
    var vm: PhrasesTextbookViewModel!
    var item: MTextbookPhrase!
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
        tfPhraseID.text = String(item.PHRASEID)
        tfPhrase.text = item.PHRASE
        tfTranslation.text = item.TRANSLATION
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

    func onDone() {
        item.SEQNUM = Int(tfSeqNum.text!)!
        item.PHRASE = vm.vmSettings.autoCorrectInput(text: tfPhrase.text ?? "")
        item.TRANSLATION = tfTranslation.text
    }
    
}
