//
//  WordsUnitBatchViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

class WordsUnitBatchViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var tfSeqNum: UITextField!
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
        ddUnit.dataSource = vm.vmSettings.arrUnits.map { $0.label }
        ddUnit.selectRow(vm.vmSettings.arrUnits.firstIndex { $0.value == item.UNIT }!)
        ddUnit.selectionAction = { (index: Int, item: String) in
            self.item.UNIT = self.vm.vmSettings.arrUnits[index].value
            self.tfUnit.text = String(self.item.UNIT)
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vm.vmSettings.arrParts.map { $0.label }
        ddPart.selectRow(vm.vmSettings.arrUnits.firstIndex { $0.value == item.PART }!)
        ddPart.selectionAction = { (index: Int, item: String) in
            self.item.PART = self.vm.vmSettings.arrParts[index].value
            self.tfPart.text = self.item.PARTSTR
        }

        tfUnit.text = String(item.UNIT)
        tfPart.text = item.PARTSTR
        tfSeqNum.text = String(item.SEQNUM)
        tfLevel.text = String(item.LEVEL)
        tfAccuracy.text = item.ACCURACY
        isAdd = item.ID == 0
        // https://stackoverflow.com/questions/7525437/how-to-set-focus-to-a-textfield-in-iphone
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 5 : 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "WordCell" + (indexPath.section == 0 ? "0\(indexPath.row)" : "10")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WordsUnitBatchCell
        if indexPath.section == 0 {
            cell.tf.tag = indexPath.row + 1
        } else {
            let item = vm.arrWords[indexPath.row]
            cell.lblUnitPartSeqNum.text = item.UNITPARTSEQNUM
            cell.lblWordNote.text = item.WORDNOTE
            cell.swSelected.tag = indexPath.row + 10
        }
        return cell
    }
}

class WordsUnitBatchCell: UITableViewCell {
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var lblUnitPartSeqNum: UILabel!
    @IBOutlet weak var lblWordNote: UILabel!
    @IBOutlet weak var swSelected: UISwitch!
}
