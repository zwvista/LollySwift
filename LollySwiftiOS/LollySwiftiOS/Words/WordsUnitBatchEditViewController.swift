//
//  WordsUnitBatchEditViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/23.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit
import Combine

class WordsUnitBatchEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tvActions: UITableView!
    @IBOutlet weak var tvWords: UITableView!
    @IBOutlet weak var swUnit: UISwitch!
    @IBOutlet weak var tfUnit: UITextField!
    @IBOutlet weak var btnUnit: UIButton!
    @IBOutlet weak var swPart: UISwitch!
    @IBOutlet weak var tfPart: UITextField!
    @IBOutlet weak var btnPart: UIButton!
    @IBOutlet weak var swSeqNum: UISwitch!
    @IBOutlet weak var tfSeqNum: UITextField!
    @IBOutlet weak var tfAccuracy: UITextField!

    var vm: WordsUnitViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textField === tfSeqNum ? swSeqNum.isOn : true
    }

    func onDone() async {
        let unit = vmSettings.arrUnits.first { $0.label == tfUnit.text }!.value
        let part = vmSettings.arrParts.first { $0.label == tfPart.text }!.value
        let seqnum = Int(tfSeqNum.text ?? "") ?? 0
        for i in 0..<vm.arrWords.count {
            let cell = tvWords.cellForRow(at: IndexPath(row: i, section: 0))!
            guard cell.accessoryType == .checkmark else {continue}
            let item = vm.arrWords[i]
            if swUnit.isOn || swPart.isOn || swSeqNum.isOn {
                if swUnit.isOn { item.UNIT = unit }
                if swPart.isOn { item.PART = part }
                if swSeqNum.isOn { item.SEQNUM += seqnum }
                await vm.update(item: item)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === tvActions ? 4 : vm.arrWords.count
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        tableView === tvActions ? UITableView.automaticDimension : 88
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "WordCell" + (tableView === tvActions ? "0\(indexPath.row)" : "10")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WordsUnitBatchEditCell
        if tableView === tvActions {
            switch indexPath.row {
            case 0:
                tfUnit = cell.tf
                tfUnit.text = vmSettings.arrUnits.first { $0.value == vmSettings.USUNITTO }!.label
                btnUnit = cell.btn
                swUnit = cell.sw

                func configMenuUnit() {
                    btnUnit.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrUnits.map(\.label).enumerated().map { index, item in
                        UIAction(title: item, state: item == tfUnit.text ? .on : .off) { [unowned self] _ in
                            tfUnit.text = item
                            configMenuUnit()
                        }
                    })
                    btnUnit.showsMenuAsPrimaryAction = true
                }
                configMenuUnit()
            case 1:
                tfPart = cell.tf
                tfPart.text = vmSettings.arrParts.first { $0.value == vmSettings.USPARTTO }!.label
                btnPart = cell.btn
                swPart = cell.sw

                func configMenuPart() {
                    btnPart.menu = UIMenu(title: "", options: .displayInline, children: vmSettings.arrParts.map(\.label).enumerated().map { index, item in
                        UIAction(title: item, state: item == tfPart.text ? .on : .off) { [unowned self] _ in
                            tfPart.text = item
                            configMenuPart()
                        }
                    })
                    btnPart.showsMenuAsPrimaryAction = true
                }
                configMenuPart()
            case 2:
                tfSeqNum = cell.tf
                swSeqNum = cell.sw
            default: break
            }
        } else {
            let item = vm.arrWords[indexPath.row]
            cell.lblUnitPartSeqNum.text = item.UNITPARTSEQNUM
            cell.lblWord.text = item.WORD
            cell.lblNote.text = item.NOTE
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView === tvWords else {return}
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = cell.accessoryType == .none ? .checkmark : .none
    }
}

class WordsUnitBatchEditCell: WordsCommonCell {
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var sw: UISwitch!
}
