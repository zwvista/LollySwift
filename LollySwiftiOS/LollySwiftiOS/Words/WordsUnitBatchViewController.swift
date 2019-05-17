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
    let ddUnit = DropDown()
    let ddPart = DropDown()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ddUnit.anchorView = tfUnit
        ddUnit.dataSource = vm.vmSettings.arrUnits.map { $0.label }
        ddUnit.selectionAction = { (index: Int, item: String) in
        }
        
        ddPart.anchorView = tfPart
        ddPart.dataSource = vm.vmSettings.arrParts.map { $0.label }
        ddPart.selectionAction = { (index: Int, item: String) in
        }

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
            if indexPath.row < 4 {
                cell.tf.tag = indexPath.row + 1
            }
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
