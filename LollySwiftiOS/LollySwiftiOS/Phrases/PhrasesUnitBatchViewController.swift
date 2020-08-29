//
//  PhrasesUnitBatchViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import NSObject_Rx

class PhrasesUnitBatchViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var swUnit: UISwitch!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var swPart: UISwitch!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var swSeqNum: UISwitch!
    @IBOutlet weak var tfSeqNum: UITextField!

    var vm: PhrasesUnitViewModel!
    let ddUnit = DropDown()
    let ddPart = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === tfUnit {
            if swUnit.isOn {
                self.view.endEditing(true)
                ddUnit.show()
            }
            return false
        } else if textField === tfPart {
            if swPart.isOn {
                self.view.endEditing(true)
                ddPart.show()
            }
            return false
        } else {
            return textField === tfSeqNum ? swSeqNum.isOn : true
        }
    }
    
    func onDone() {
        var o = Observable.just(())
        let unit = vmSettings.arrUnits[ddUnit.indexForSelectedRow!].value
        let part = vmSettings.arrParts[ddPart.indexForSelectedRow!].value
        let seqnum = tfSeqNum.text?.toInt() ?? 0
        for i in 0..<vm.arrPhrases.count {
            let cell = tableView.cellForRow(at: IndexPath(row: i, section: 1))!
            guard cell.accessoryType == .checkmark else {continue}
            let item = vm.arrPhrases[i]
            if swUnit.isOn || swPart.isOn || swSeqNum.isOn {
                if swUnit.isOn { item.UNIT = unit }
                if swPart.isOn { item.PART = part }
                if swSeqNum.isOn { item.SEQNUM += seqnum }
                o = o.concat(vm.update(item: item).map {_ in })
            }
        }
        o.subscribe() ~ rx.disposeBag
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 3 : vm.arrPhrases.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        indexPath.section == 0 ? UITableView.automaticDimension : 88
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "PhraseCell" + (indexPath.section == 0 ? "0\(indexPath.row)" : "10")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PhrasesUnitBatchCell
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                tfUnit = cell.tf
                tfUnit.text = vmSettings.arrUnits.first { $0.value == vmSettings.USUNITTO }!.label
                ddUnit.anchorView = tfUnit
                ddUnit.dataSource = vmSettings.arrUnits.map { $0.label }
                ddUnit.selectRow(vmSettings.arrUnits.firstIndex { $0.value == vmSettings.USUNITTO }!)
                ddUnit.selectionAction = { [unowned self] (index: Int, item: String) in
                    self.tfUnit.text = item
                }
                swUnit = cell.sw
            case 1:
                tfPart = cell.tf
                tfPart.text = vmSettings.arrParts.first { $0.value == vmSettings.USPARTTO }!.label
                ddPart.anchorView = tfPart
                ddPart.dataSource = vmSettings.arrParts.map { $0.label }
                ddPart.selectRow(vmSettings.arrParts.firstIndex { $0.value == vmSettings.USPARTTO }!)
                ddPart.selectionAction = { [unowned self] (index: Int, item: String) in
                    self.tfPart.text = item
                }
                swPart = cell.sw
            case 2:
                tfSeqNum = cell.tf
                swSeqNum = cell.sw
            default: break
            }
        } else {
            let item = vm.arrPhrases[indexPath.row]
            cell.lblUnitPartSeqNum.text = item.UNITPARTSEQNUM
            cell.lblPhrase!.text = item.PHRASE
            cell.lblTranslation!.text = item.TRANSLATION
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else {return}
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
    }
}

class PhrasesUnitBatchCell: PhrasesCommonCell {
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var sw: UISwitch!
}
