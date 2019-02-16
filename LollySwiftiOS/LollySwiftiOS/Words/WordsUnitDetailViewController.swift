//
//  WordsUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

class WordsUnitDetailViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    
    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var isAdd: Bool!
    let ddUnit = DropDown()
    let ddPart = DropDown()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vm.vmSettings.arrUnits
        ddUnit.selectRow(item.UNIT - 1)
        ddUnit.selectionAction = { (index: Int, item: String) in
            self.item.UNIT = index + 1
            self.tfUnit.text = String(self.item.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vm.vmSettings.arrParts
        ddPart.selectRow(item.PART - 1)
        ddPart.selectionAction = { (index: Int, item: String) in
            self.item.PART = index + 1
            self.tfPart.text = self.item.PARTSTR(arrParts: vmSettings.arrParts)
        }

        tfID.text = String(item.ID)
        tfUnit.text = String(item.UNIT)
        tfPart.text = item.PARTSTR(arrParts: vmSettings.arrParts)
        tfSeqNum.text = String(item.SEQNUM)
        tfWord.text = item.WORD
        tfNote.text = item.NOTE
        isAdd = item.ID == 0
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
        (item.WORD.isEmpty ? tfWord : tfNote)?.becomeFirstResponder()
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
        if isAdd {
            if !item.WORD.isEmpty {
                vm.arrWords.append(item)
                WordsUnitViewModel.create(item: item).subscribe(onNext: {
                    self.item.ID = $0
                }).disposed(by: disposeBag)
            }
        } else {
            WordsUnitViewModel.update(item: item).subscribe().disposed(by: disposeBag)
        }
    }
    
}
