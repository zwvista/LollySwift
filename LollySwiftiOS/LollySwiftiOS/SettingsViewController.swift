//
//  SettingsViewController.swift
//  LollySwiftiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, ActionSheetCustomPickerDelegate {    
    @IBOutlet weak var langCell: UITableViewCell!
    @IBOutlet weak var dictCell: UITableViewCell!
    @IBOutlet weak var textbookCell: UITableViewCell!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var swUnitTo: UISwitch!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    @IBOutlet weak var lblUnitToTitle: UILabel!
    @IBOutlet weak var lblPartToTitle: UILabel!
    
    var selectedIndexPath: IndexPath!
    var selectedRow = 0
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch selectedIndexPath.section {
        case 0:
            ActionSheetCustomPicker.show(withTitle: "Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [vm.selectedLangIndex])
        case 1:
            ActionSheetCustomPicker.show(withTitle: "Select Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [vm.selectedDictIndex])
        case 2:
            ActionSheetCustomPicker.show(withTitle: "Select Textbook", delegate: self, showCancelButton: true, origin: textbookCell, initialSelections: [vm.selectedTextbookIndex])
        default:
            let isInvalidUnitPart = { self.vm.USUNITPARTFROM > self.vm.USUNITPARTTO }
            switch selectedIndexPath.row {
            case 0:
                ActionSheetStringPicker.show(withTitle: "Select Unit(From)", rows: vm.arrUnits, initialSelection: vm.USUNITFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    self.vm.USUNITFROM = selectedValue as! Int
                    MUserSetting.update(textbookid: self.vm.USTEXTBOOKID, usunitfrom: self.vm.USUNITFROM) { [unowned self] result in
                        print(result)
                        self.lblUnitFrom.text = (selectedValue as! String)
                        if !self.swUnitTo.isOn || isInvalidUnitPart() {self.updateUnitPartTo()}
                    }
                }, cancel: nil, origin: lblUnitFrom)
            case 1:
                ActionSheetStringPicker.show(withTitle: "Select Part(From)", rows: vm.arrParts, initialSelection: vm.USPARTFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    self.vm.USPARTFROM = selectedValue as! Int
                    MUserSetting.update(textbookid: self.vm.USTEXTBOOKID, uspartfrom: self.vm.USPARTFROM) { [unowned self] result in
                        print(result)
                        self.lblPartFrom.text = (selectedValue as! String)
                        if !self.swUnitTo.isOn || isInvalidUnitPart() {self.updateUnitPartTo()}
                    }
                }, cancel: nil, origin: lblPartFrom)
            case 3 where swUnitTo.isOn:
                ActionSheetStringPicker.show(withTitle: "Select Unit(To)", rows: vm.arrUnits, initialSelection: vm.USUNITTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    self.vm.USUNITTO = selectedValue as! Int
                    MUserSetting.update(textbookid: self.vm.USTEXTBOOKID, usunitto: self.vm.USUNITTO) { [unowned self] result in
                        print(result)
                        self.lblUnitTo.text = (selectedValue as! String)
                        if isInvalidUnitPart() {self.updateUnitPartFrom()}
                    }
                }, cancel: nil, origin: lblUnitTo)
            case 4 where swUnitTo.isOn:
                ActionSheetStringPicker.show(withTitle: "Select Part(To)", rows: vm.arrParts, initialSelection: vm.USPARTTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    self.vm.USPARTTO = selectedValue as! Int
                    MUserSetting.update(textbookid: self.vm.USTEXTBOOKID, uspartto: self.vm.USPARTTO) { [unowned self] result in
                        print(result)
                        self.lblPartTo.text = (selectedValue as! String)
                        if isInvalidUnitPart() {self.updateUnitPartFrom()}
                    }
                }, cancel: nil, origin: lblPartTo)
            default:
                break
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedIndexPath.section {
        case 0:
            return vm.arrLanguages.count
        case 1:
            return vm.arrDictionaries.count
        case 2:
            return vm.arrTextbooks.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return vm.arrLanguages[row].NAME
        case 1:
            return vm.arrDictionaries[row].DICTNAME
        case 2:
            return vm.arrTextbooks[row].NAME
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func actionSheetPickerDidSucceed(_ actionSheetPicker: AbstractActionSheetPicker!, origin: Any!) {
        switch selectedIndexPath.section {
        case 0 where selectedRow != vm.selectedLangIndex:
            vm.setSelectedLangIndex(selectedRow) { [unowned self] in
                self.updateLang()
            }
        case 1 where selectedRow != vm.selectedDictIndex:
            vm.selectedDictIndex = selectedRow
            updateDict()
        case 2 where selectedRow != vm.selectedTextbookIndex:
            vm.selectedTextbookIndex = selectedRow
            updateTextbook()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = vm.selectedLang
        langCell.textLabel!.text = m.NAME
        updateDict()
        updateTextbook()
    }
    
    func updateDict() {
        let m = vm.selectedDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateTextbook() {
        let m = vm.selectedTextbook
        textbookCell.textLabel!.text = m.NAME
        textbookCell.detailTextLabel!.text = "\(m.UNITS!) Units"
        lblUnitFrom.text = "\(vm.USUNITFROM)"
        lblUnitTo.text = "\(vm.USUNITTO)"
        lblPartFrom.text = vm.arrParts[vm.USPARTFROM - 1]
        lblPartTo.text = vm.arrParts[vm.USPARTTO - 1]
        swUnitTo.isOn = !vm.isSingleUnitPart
        swUnitToValueChanged(self)
    }
    
    func updateUnitPartFrom() {
        vm.USUNITFROM = vm.USUNITTO
        lblUnitFrom.text = lblUnitTo.text
        vm.USPARTFROM = vm.USPARTTO
        lblPartFrom.text = lblPartTo.text
    }
    
    func updateUnitPartTo() {
        vm.USUNITTO = vm.USUNITFROM
        lblUnitTo.text = lblUnitFrom.text
        vm.USPARTTO = vm.USPARTFROM
        lblPartTo.text = lblPartFrom.text
    }
    
    @IBAction func swUnitToValueChanged(_ sender: AnyObject) {
        lblUnitTo.isEnabled = swUnitTo.isOn
        lblPartTo.isEnabled = swUnitTo.isOn
        lblUnitToTitle.isEnabled = swUnitTo.isOn
        lblPartToTitle.isEnabled = swUnitTo.isOn
        if sender !== self && !swUnitTo.isOn {self.updateUnitPartTo()}
    }
}
