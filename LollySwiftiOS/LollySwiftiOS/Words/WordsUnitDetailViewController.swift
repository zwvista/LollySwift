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
    @IBOutlet weak var tfWordID: UITextField!
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tfNote: UITextField!
    @IBOutlet weak var tfFamiID: UITextField!
    @IBOutlet weak var tfLevel: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!

    var vm: WordsUnitViewModel!
    var item: MUnitWord!
    var isAdd: Bool!
    let ddUnit = DropDown()
    let ddPart = DropDown()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vmSettings.arrUnits.map { $0.label }
        ddUnit.selectRow(vmSettings.arrUnits.firstIndex { $0.value == item.UNIT }!)
        ddUnit.selectionAction = { (index: Int, item: String) in
            self.item.UNIT = vmSettings.arrUnits[index].value
            self.tfUnit.text = item
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vmSettings.arrParts.map { $0.label }
        ddPart.selectRow(vmSettings.arrParts.firstIndex { $0.value == item.PART }!)
        ddPart.selectionAction = { (index: Int, item: String) in
            self.item.PART = vmSettings.arrParts[index].value
            self.tfPart.text = item
        }

        tfID.text = String(item.ID)
        tfUnit.text = String(item.UNIT)
        tfPart.text = item.PARTSTR
        tfSeqNum.text = String(item.SEQNUM)
        tfWordID.text = String(item.WORDID)
        tfWord.text = item.WORD
        tfNote.text = item.NOTE
        tfFamiID.text = String(item.FAMIID)
        tfLevel.text = String(item.LEVEL)
        tfAccuracy.text = item.ACCURACY
        isAdd = item.ID == 0
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
        item.WORD = vmSettings.autoCorrectInput(text: tfWord.text ?? "")
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
