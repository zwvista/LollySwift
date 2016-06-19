//
//  SettingsViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/16.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, ActionSheetCustomPickerDelegate {
    let theWordsOnlineViewModel = (UIApplication.sharedApplication().delegate as! AppDelegate).theWordsOnlineViewModel
    
    @IBOutlet weak var langCell: UITableViewCell!
    @IBOutlet weak var dictCell: UITableViewCell!
    @IBOutlet weak var bookCell: UITableViewCell!
    @IBOutlet weak var tfUnitFrom: UITextField!
    @IBOutlet weak var tfUnitTo: UITextField!
    @IBOutlet weak var swUnitTo: UISwitch!
    @IBOutlet weak var lblPartFrom: UILabel!
    @IBOutlet weak var lblPartTo: UILabel!
    
    var selectedIndexPath = NSIndexPath()
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            ActionSheetCustomPicker.showPickerWithTitle("Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [theWordsOnlineViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [theWordsOnlineViewModel.currentDictIndex])
        case 2:
            ActionSheetCustomPicker.showPickerWithTitle("Select Book", delegate: self, showCancelButton: true, origin: bookCell, initialSelections: [theWordsOnlineViewModel.currentBookIndex])
        case 3:
            if selectedIndexPath.row == 0 {
                ActionSheetCustomPicker.showPickerWithTitle("Select Part", delegate: self, showCancelButton: true, origin: lblPartFrom, initialSelections: [theWordsOnlineViewModel.currentBook.PARTFROM - 1])
            } else if selectedIndexPath.row == 2 {
                ActionSheetCustomPicker.showPickerWithTitle("Select Part", delegate: self, showCancelButton: true, origin: lblPartTo, initialSelections: [theWordsOnlineViewModel.currentBook.PARTTO - 1])
            }
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
            return theWordsOnlineViewModel.arrLanguages.count
        case 1:
            return theWordsOnlineViewModel.arrDictAll.count
        case 2:
            return theWordsOnlineViewModel.arrBooks.count
        case 3:
            return theWordsOnlineViewModel.currentBook.partsAsArray.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return theWordsOnlineViewModel.arrLanguages[row].LANGNAME
        case 1:
            return theWordsOnlineViewModel.arrDictAll[row].DICTNAME
        case 2:
            return theWordsOnlineViewModel.arrBooks[row].BOOKNAME
        case 3:
            return theWordsOnlineViewModel.currentBook.partsAsArray[row]
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
            if selectedRow == theWordsOnlineViewModel.currentLangIndex {return}
            theWordsOnlineViewModel.currentLangIndex = selectedRow
            updateLang()
        case 1:
            if selectedRow == theWordsOnlineViewModel.currentDictIndex {return}
            theWordsOnlineViewModel.currentDictIndex = selectedRow
            updateDict()
        case 1:
            if selectedRow == theWordsOnlineViewModel.currentBookIndex {return}
            theWordsOnlineViewModel.currentBookIndex = selectedRow
            updateBook()
        case 2:
            let m = theWordsOnlineViewModel.currentBook
            if selectedIndexPath.row == 0 {
                if selectedRow == m.PARTFROM - 1 {return}
                m.PARTFROM = selectedRow + 1
                lblPartFrom.text = m.partsAsArray[selectedRow]
            } else if selectedIndexPath.row == 2 {
                if selectedRow == m.PARTTO - 1 {return}
                m.PARTTO = selectedRow + 1
                lblPartTo.text = m.partsAsArray[selectedRow]
            }
        default:
            break
        }
    }
    
    func updateLang() {
        let m = theWordsOnlineViewModel.currentLang
        langCell.textLabel!.text = m.LANGNAME
        updateDict()
        updateBook()
    }
    
    func updateDict() {
        let m = theWordsOnlineViewModel.currentDict
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
    func updateBook() {
        let m = theWordsOnlineViewModel.currentBook
        bookCell.textLabel!.text = m.BOOKNAME
        bookCell.detailTextLabel!.text = "\(m.UNITSINBOOK) Units"
        tfUnitFrom.text = "\(m.UNITFROM)"
        tfUnitTo.text = "\(m.UNITTO)"
        swUnitTo.on = m.UNITFROM != m.UNITTO
        swUnitToValueChanged(self)
        lblPartFrom.text = m.partsAsArray[m.PARTFROM - 1]
        lblPartTo.text = m.partsAsArray[m.PARTTO - 1]
    }
    
    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        tfUnitTo.enabled = swUnitTo.on
    }
}
