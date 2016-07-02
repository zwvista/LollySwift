//
//  SettingsViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, ActionSheetCustomPickerDelegate {
    let theSettingsViewModel = (UIApplication.sharedApplication().delegate as! AppDelegate).theSettingsViewModel
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        switch selectedIndexPath.section {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [theSettingsViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [theSettingsViewModel.currentDictIndex])
        case 2:
            ActionSheetCustomPicker.showPickerWithTitle("Select Book", delegate: self, showCancelButton: true, origin: bookCell, initialSelections: [theSettingsViewModel.currentBookIndex])
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
            return theSettingsViewModel.arrLanguages.count
        case 1:
            return theSettingsViewModel.arrDictAll.count
        case 2:
            return theSettingsViewModel.arrBooks.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return theSettingsViewModel.arrLanguages[row].LANGNAME
        case 1:
            return theSettingsViewModel.arrDictAll[row].DICTNAME
        case 2:
            return theSettingsViewModel.arrBooks[row].BOOKNAME
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
            if selectedRow == theSettingsViewModel.currentLangIndex {return}
            theSettingsViewModel.currentLangIndex = selectedRow
            updateLang()
        case 1:
            if selectedRow == theSettingsViewModel.currentDictIndex {return}
            theSettingsViewModel.currentDictIndex = selectedRow
            updateDict()
        case 2:
            if selectedRow == theSettingsViewModel.currentBookIndex {return}
            theSettingsViewModel.currentBookIndex = selectedRow
            updateBook()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = theSettingsViewModel.currentLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateBook()
    }
    
    func updateDict() {
        let m = theSettingsViewModel.currentDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateBook() {
        let m = theSettingsViewModel.currentBook
        bookCell.textLabel!.text = m.BOOKNAME
        bookCell.detailTextLabel!.text = "\(m.UNITSINBOOK) Units"
        lblUnitFrom.text = "\(m.UNITFROM)"
        lblUnitTo.text = "\(m.UNITTO)"
        swUnitTo.on = m.UNITFROM != m.UNITTO
        swUnitToValueChanged(self)
        lblPartFrom.text = m.partsAsArray[m.PARTFROM - 1]
        lblPartTo.text = m.partsAsArray[m.PARTTO - 1]
    }
    
    @IBAction func labelTap(sender: AnyObject) {
        let lbl = (sender as! UITapGestureRecognizer).view as! UILabel
        let m = self.theSettingsViewModel.currentBook
        if lbl === lblUnitFrom {
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(From)", rows: m.unitsAsArray, initialSelection: m.UNITFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.UNITFROM = selectedIndex + 1
                self.lblUnitFrom.text = m.unitsAsArray[selectedIndex]
                if !self.swUnitTo.on {
                    m.UNITTO = m.UNITFROM
                    self.lblUnitTo.text = self.lblUnitFrom.text
                }
            }, cancelBlock: nil, origin: lblUnitFrom)
        } else if lbl === lblUnitTo && swUnitTo.on {
            ActionSheetStringPicker.showPickerWithTitle("Select Unit(To)", rows: m.unitsAsArray, initialSelection: m.UNITTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.UNITTO = selectedIndex + 1
                self.lblUnitTo.text = m.unitsAsArray[selectedIndex]
            }, cancelBlock: nil, origin: lblUnitTo)
        } else if lbl === lblPartFrom {
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.PARTFROM - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.PARTFROM = selectedIndex + 1
                self.lblPartFrom.text = m.partsAsArray[selectedIndex]
                if !self.swUnitTo.on {
                    m.PARTTO = m.PARTFROM
                    self.lblPartTo.text = self.lblPartFrom.text
                }
            }, cancelBlock: nil, origin: lblPartFrom)
        } else if lbl === lblPartTo && swUnitTo.on {
            ActionSheetStringPicker.showPickerWithTitle("Select Part", rows: m.partsAsArray, initialSelection: m.PARTTO - 1, doneBlock: { (picker, selectedIndex, selectedValue) in
                m.PARTTO = selectedIndex + 1
                self.lblPartTo.text = m.partsAsArray[selectedIndex]
            }, cancelBlock: nil, origin: lblPartTo)
        }
    }
    
    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        lblUnitTo.enabled = swUnitTo.on
        lblPartTo.enabled = swUnitTo.on
        if !swUnitTo.on {
            let m = self.theSettingsViewModel.currentBook
            m.UNITTO = m.UNITFROM
            lblUnitTo.text = lblUnitFrom.text
            m.PARTTO = m.PARTFROM
            lblPartTo.text = lblPartFrom.text
        }
    }
}
