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
    
    var selectedIndexPath: NSIndexPath!
    var selectedRow = 0
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        switch selectedIndexPath.section {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [vm.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [vm.currentDictIndex])
        case 2:
            ActionSheetCustomPicker.showPickerWithTitle("Select Textbook", delegate: self, showCancelButton: true, origin: textbookCell, initialSelections: [vm.currentTextbookIndex])
        default:
            let m = vm.currentTextbook
            let isInvalidUnitPart = {m.USUNITFROM * 10 + m.USPARTFROM > m.USUNITTO * 10 + m.USPARTTO}
            switch selectedIndexPath.row {
            case 0:
                ActionSheetStringPicker.showPickerWithTitle("Select Unit(From)", rows: vm.arrUnits, initialSelection: m.USUNITFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    m.USUNITFROM = Int(selectedValue as! String)!
                    self.lblUnitFrom.text = (selectedValue as! String)
                    if !self.swUnitTo.on || isInvalidUnitPart() {self.updateUnitPartTo()}
                }, cancelBlock: nil, origin: lblUnitFrom)
            case 1:
                ActionSheetStringPicker.showPickerWithTitle("Select Part(From)", rows: vm.arrParts, initialSelection: m.USPARTFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    m.USPARTFROM = Int(selectedValue as! String)!
                    self.lblPartFrom.text = (selectedValue as! String)
                    if !self.swUnitTo.on || isInvalidUnitPart() {self.updateUnitPartTo()}
                }, cancelBlock: nil, origin: lblPartFrom)
            case 3 where swUnitTo.on:
                ActionSheetStringPicker.showPickerWithTitle("Select Unit(To)", rows: vm.arrUnits, initialSelection: m.USUNITTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    m.USUNITTO = Int(selectedValue as! String)!
                    self.lblUnitTo.text = (selectedValue as! String)
                    if isInvalidUnitPart() {self.updateUnitPartFrom()}
                }, cancelBlock: nil, origin: lblUnitTo)
            case 4 where swUnitTo.on:
                ActionSheetStringPicker.showPickerWithTitle("Select Part(To)", rows: vm.arrParts, initialSelection: m.USPARTTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                    m.USPARTTO = Int(selectedValue as! String)!
                    self.lblPartTo.text = (selectedValue as! String)
                    if isInvalidUnitPart() {self.updateUnitPartFrom()}
                }, cancelBlock: nil, origin: lblPartTo)
            default:
                break
            }
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return vm.arrLanguages[row].LANGNAME
        case 1:
            return vm.arrDictionaries[row].DICTNAME
        case 2:
            return vm.arrTextbooks[row].TEXTBOOKNAME
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        switch selectedIndexPath.section {
        case 0 where selectedRow != vm.currentLangIndex:
            vm.currentLangIndex = selectedRow
            updateLang()
        case 1 where selectedRow != vm.currentDictIndex:
            vm.currentDictIndex = selectedRow
            updateDict()
        case 2 where selectedRow != vm.currentTextbookIndex:
            vm.currentTextbookIndex = selectedRow
            updateTextbook()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = vm.currentLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateTextbook()
    }
    
    func updateDict() {
        let m = vm.currentDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateTextbook() {
        let m = vm.currentTextbook
        textbookCell.textLabel!.text = m.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(m.UNITS) Units"
        lblUnitFrom.text = "\(m.USUNITFROM)"
        lblUnitTo.text = "\(m.USUNITTO)"
        lblPartFrom.text = vm.arrParts[m.USPARTFROM - 1]
        lblPartTo.text = vm.arrParts[m.USPARTTO - 1]
        swUnitTo.on = !m.isSingleUnitPart
        swUnitToValueChanged(self)
    }
    
    func updateUnitPartFrom() {
        let m = vm.currentTextbook
        m.USUNITFROM = m.USUNITTO
        lblUnitFrom.text = lblUnitTo.text
        m.USPARTFROM = m.USPARTTO
        lblPartFrom.text = lblPartTo.text
    }
    
    func updateUnitPartTo() {
        let m = vm.currentTextbook
        m.USUNITTO = m.USUNITFROM
        lblUnitTo.text = lblUnitFrom.text
        m.USPARTTO = m.USPARTFROM
        lblPartTo.text = lblPartFrom.text
    }
    
    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        lblUnitTo.enabled = swUnitTo.on
        lblPartTo.enabled = swUnitTo.on
        if sender !== self && !swUnitTo.on {self.updateUnitPartTo()}
    }
}
