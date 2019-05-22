//
//  PhrasesUnitDetailViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

class PhrasesUnitDetailViewController: UITableViewController, UITextFieldDelegate {
 
    @IBOutlet weak var tfID: UITextField!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfPhraseID: UITextField!
    @IBOutlet weak var tfPhrase: UITextField!
    @IBOutlet weak var tfTranslation: UITextField!

    var vm: PhrasesUnitViewModel!
    var item: MUnitPhrase!
    var isAdd: Bool!
    let ddUnit = DropDown()
    let ddPart = DropDown()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vmSettings.arrUnits.map { $0.label }
        ddUnit.selectRow(vmSettings.arrUnits.firstIndex { $0.value == item.UNIT }!)
        ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
            self.item.UNIT = vmSettings.arrUnits[index].value
            self.tfUnit.text = String(self.item.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vmSettings.arrParts.map { $0.label }
        ddPart.selectRow(vmSettings.arrUnits.firstIndex { $0.value == item.PART }!)
        ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
            self.item.PART = vmSettings.arrParts[index].value
            self.tfPart.text = self.item.PARTSTR
        }
        
        tfID.text = String(item.ID)
        tfUnit.text = String(item.UNIT)
        tfPart.text = item.PARTSTR
        tfSeqNum.text = String(item.SEQNUM)
        tfPhraseID.text = String(item.PHRASEID)
        tfPhrase.text = item.PHRASE
        tfTranslation.text = item.TRANSLATION
        isAdd = item.ID == 0
        (item.PHRASE.isEmpty ? tfPhrase : tfTranslation)?.becomeFirstResponder()
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
        item.PHRASE = vmSettings.autoCorrectInput(text: tfPhrase.text ?? "")
        item.TRANSLATION = tfTranslation.text
        if isAdd {
            vm.arrPhrases.append(item)
            PhrasesUnitViewModel.create(item: item).subscribe(onNext: {
                self.item.ID = $0
            }).disposed(by: disposeBag)
        } else {
            PhrasesUnitViewModel.update(item: item).subscribe().disposed(by: disposeBag)
        }
    }
    
}
