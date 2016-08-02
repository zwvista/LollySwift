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
    @IBOutlet weak var bookCell: UITableViewCell!
    @IBOutlet weak var lblUnitFrom: UILabel!
    @IBOutlet weak var lblUnitTo: UILabel!
    @IBOutlet weak var swUnitTo: UISwitch!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    
    var selectedIndexPath = NSIndexPath()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(SettingsViewController.labelTap))
        lblUnitFrom.addGestureRecognizer(tapGesture)
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(SettingsViewController.labelTap))
        lblUnitTo.addGestureRecognizer(tapGesture)
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(SettingsViewController.labelTap))
        lblPartFrom.addGestureRecognizer(tapGesture)
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(SettingsViewController.labelTap))
        lblPartTo.addGestureRecognizer(tapGesture)
        
        updateLang()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        switch selectedIndexPath.section {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [AppDelegate.theSettingsViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [AppDelegate.theSettingsViewModel.currentDictIndex])
        case 2:
            ActionSheetCustomPicker.showPickerWithTitle("Select Book", delegate: self, showCancelButton: true, origin: bookCell, initialSelections: [AppDelegate.theSettingsViewModel.currentBookIndex])
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
            return AppDelegate.theSettingsViewModel.arrLanguages.count
        case 1:
            return AppDelegate.theSettingsViewModel.arrDictAll.count
        case 2:
            return AppDelegate.theSettingsViewModel.arrBooks.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return AppDelegate.theSettingsViewModel.arrLanguages[row].LANGNAME
        case 1:
            return AppDelegate.theSettingsViewModel.arrDictAll[row].DICTNAME
        case 2:
            return AppDelegate.theSettingsViewModel.arrBooks[row].TEXTBOOKNAME
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        switch selectedIndexPath.section {
        case 0:
            if selectedRow == AppDelegate.theSettingsViewModel.currentLangIndex {return}
            AppDelegate.theSettingsViewModel.currentLangIndex = selectedRow
            updateLang()
        case 1:
            if selectedRow == AppDelegate.theSettingsViewModel.currentDictIndex {return}
            AppDelegate.theSettingsViewModel.currentDictIndex = selectedRow
            updateDict()
        case 2:
            if selectedRow == AppDelegate.theSettingsViewModel.currentBookIndex {return}
            AppDelegate.theSettingsViewModel.currentBookIndex = selectedRow
            updateBook()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = AppDelegate.theSettingsViewModel.currentLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateBook()
    }
    
    func updateDict() {
        let m = AppDelegate.theSettingsViewModel.currentDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateBook() {
        let m = AppDelegate.theSettingsViewModel.currentBook
        bookCell.textLabel!.text = m.TEXTBOOKNAME
        bookCell.detailTextLabel!.text = "\(m.UNITS) Units"
        lblUnitFrom.text = "\(m.USUNITFROM)"
        lblUnitTo.text = "\(m.USUNITTO)"
        swUnitTo.on = m.USUNITFROM != m.USUNITTO
        swUnitToValueChanged(self)
        lblPartFrom.text = m.partsAsArray[m.USPARTFROM - 1]
        lblPartTo.text = m.partsAsArray[m.USPARTTO - 1]
    }
    
    @IBAction func labelTap(sender: AnyObject) {
        let lbl = (sender as! UITapGestureRecognizer).view as! UILabel
        let m = AppDelegate.theSettingsViewModel.currentBook
        if lbl === lblUnitFrom {
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(From)", rows: m.unitsAsArray, initialSelection: m.USUNITFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USUNITFROM = selectedIndex + 1
                self.lblUnitFrom.text = m.unitsAsArray[selectedIndex]
                if !self.swUnitTo.on {
                    m.USUNITTO = m.USUNITFROM
                    self.lblUnitTo.text = self.lblUnitFrom.text
                }
            }, cancelBlock: nil, origin: lblUnitFrom)
        } else if lbl === lblUnitTo && swUnitTo.on {
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(To)", rows: m.unitsAsArray, initialSelection: m.USUNITTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USUNITTO = selectedIndex + 1
                self.lblUnitTo.text = m.unitsAsArray[selectedIndex]
            }, cancelBlock: nil, origin: lblUnitTo)
        } else if lbl === lblPartFrom {
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.USPARTFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USPARTFROM = selectedIndex + 1
                self.lblPartFrom.text = m.partsAsArray[selectedIndex]
                if !self.swUnitTo.on {
                    m.USPARTTO = m.USPARTFROM
                    self.lblPartTo.text = self.lblPartFrom.text
                }
            }, cancelBlock: nil, origin: lblPartFrom)
        } else if lbl === lblPartTo && swUnitTo.on {
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.USPARTTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.USPARTTO = selectedIndex + 1
                self.lblPartTo.text = m.partsAsArray[selectedIndex]
            }, cancelBlock: nil, origin: lblPartTo)
        }
    }
    
    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        lblUnitTo.enabled = swUnitTo.on
        lblPartTo.enabled = swUnitTo.on
        if !swUnitTo.on {
            let m = AppDelegate.theSettingsViewModel.currentBook
            m.USUNITTO = m.USUNITFROM
            lblUnitTo.text = lblUnitFrom.text
            m.USPARTTO = m.USPARTFROM
            lblPartTo.text = lblPartFrom.text
        }
    }
}
