//
//  SettingsViewController.swift
//  LollyiOS
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
    
    var selectedIndexPath = NSIndexPath()
    var selectedRow = 0
    
    var vm: SettingsViewModel {
        return AppDelegate.theSettingsViewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func f(lbl: UILabel) {
            lbl.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(SettingsViewController.labelTap)))
        }
        // let f = { (lbl: UILabel) in lbl. ... }
        // let f: UILabel -> Void = { $0. ... }
        f(lblUnitFrom)
        f(lblUnitTo)
        f(lblPartFrom)
        f(lblPartTo)
        
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
            ActionSheetCustomPicker.showPickerWithTitle("Select TextBook", delegate: self, showCancelButton: true, origin: textbookCell, initialSelections: [vm.currentTextBookIndex])
        default:
            break
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
            return vm.arrDictionary.count
        case 2:
            return vm.arrTextBooks.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return vm.arrLanguages[row].LANGNAME
        case 1:
            return vm.arrDictionary[row].DICTNAME
        case 2:
            return vm.arrTextBooks[row].TEXTBOOKNAME
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
        case 2 where selectedRow != vm.currentTextBookIndex:
            vm.currentTextBookIndex = selectedRow
            updateTextBook()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = vm.currentLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateTextBook()
    }
    
    func updateDict() {
        let m = vm.currentDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateTextBook() {
        let m = vm.currentTextBook
        textbookCell.textLabel!.text = m.TEXTBOOKNAME
        textbookCell.detailTextLabel!.text = "\(m.UNITS) Units"
        lblUnitFrom.text = "\(m.USUNITFROM)"
        lblUnitTo.text = "\(m.USUNITTO)"
        swUnitTo.on = m.USUNITFROM != m.USUNITTO
        swUnitToValueChanged(self)
        lblPartFrom.text = m.partsAsArray[m.USPARTFROM - 1]
        lblPartTo.text = m.partsAsArray[m.USPARTTO - 1]
    }
    
    func updateUnitPartFrom() {
        let m = vm.currentTextBook
        m.USUNITFROM = m.USUNITTO
        lblUnitFrom.text = lblUnitTo.text
        m.USPARTFROM = m.USPARTTO
        lblPartFrom.text = lblPartTo.text
    }
    
    func updateUnitPartTo() {
        let m = vm.currentTextBook
        m.USUNITTO = m.USUNITFROM
        lblUnitTo.text = lblUnitFrom.text
        m.USPARTTO = m.USPARTFROM
        lblPartTo.text = lblPartFrom.text
    }
    
    @IBAction func labelTap(sender: AnyObject) {
        let lbl = (sender as! UITapGestureRecognizer).view as! UILabel
        let m = vm.currentTextBook
        let isInvalidUnitPart = {m.USUNITFROM * 10 + m.USPARTFROM > m.USUNITTO * 10 + m.USPARTTO}
        switch lbl {
        case lblUnitFrom:
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(From)", rows: m.unitsAsArray, initialSelection: m.USUNITFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USUNITFROM = selectedIndex + 1
                self.lblUnitFrom.text = m.unitsAsArray[selectedIndex]
                if !self.swUnitTo.on || isInvalidUnitPart() {self.updateUnitPartTo()}
            }, cancelBlock: nil, origin: lblUnitFrom)
        case lblUnitTo where swUnitTo.on:
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(To)", rows: m.unitsAsArray, initialSelection: m.USUNITTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USUNITTO = selectedIndex + 1
                self.lblUnitTo.text = m.unitsAsArray[selectedIndex]
                if isInvalidUnitPart() {self.updateUnitPartFrom()}
            }, cancelBlock: nil, origin: lblUnitTo)
        case lblPartFrom:
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.USPARTFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USPARTFROM = selectedIndex + 1
                self.lblPartFrom.text = m.partsAsArray[selectedIndex]
                if !self.swUnitTo.on || isInvalidUnitPart() {self.updateUnitPartTo()}
            }, cancelBlock: nil, origin: lblPartFrom)
        case lblPartTo where swUnitTo.on:
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.USPARTTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USPARTTO = selectedIndex + 1
                self.lblPartTo.text = m.partsAsArray[selectedIndex]
                if isInvalidUnitPart() {self.updateUnitPartFrom()}
            }, cancelBlock: nil, origin: lblPartTo)
        default: break
        }
    }
    
    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        lblUnitTo.enabled = swUnitTo.on
        lblPartTo.enabled = swUnitTo.on
        if !swUnitTo.on {self.updateUnitPartTo()}
    }
}
