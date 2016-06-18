//
//  SelectUnitsViewController.swift
//  LollyiOS
//
//  Created by 趙偉 on 2016/06/17.
//  Copyright © 2016年 趙 偉. All rights reserved.
//

import UIKit

class SelectUnitsViewController: UITableViewController, ActionSheetCustomPickerDelegate {
    let theSelectUnitsViewModel = (UIApplication.sharedApplication().delegate as! AppDelegate).theSelectUnitsViewModel
    
    @IBOutlet weak var langCell: UITableViewCell!
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
        updateBook()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        switch selectedIndexPath.section {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [theSelectUnitsViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select Book", delegate: self, showCancelButton: true, origin: bookCell, initialSelections: [theSelectUnitsViewModel.currentBookIndex])
        case 2:
            if selectedIndexPath.row == 0 {
                ActionSheetCustomPicker.showPickerWithTitle("Select Part", delegate: self, showCancelButton: true, origin: lblPartFrom, initialSelections: [theSelectUnitsViewModel.currentBook.PARTFROM - 1])
            } else if selectedIndexPath.row == 2 {
                ActionSheetCustomPicker.showPickerWithTitle("Select Part", delegate: self, showCancelButton: true, origin: lblPartTo, initialSelections: [theSelectUnitsViewModel.currentBook.PARTTO - 1])
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
            return theSelectUnitsViewModel.arrLanguages.count
        case 1:
            return theSelectUnitsViewModel.arrBooks.count
        case 2:
            return theSelectUnitsViewModel.currentBook.partsAsArray.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedIndexPath.section {
        case 0:
            return theSelectUnitsViewModel.arrLanguages[row].LANGNAME
        case 1:
            return theSelectUnitsViewModel.arrBooks[row].BOOKNAME
        case 2:
            return theSelectUnitsViewModel.currentBook.partsAsArray[row]
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
            if selectedRow == theSelectUnitsViewModel.currentLangIndex {return}
            theSelectUnitsViewModel.currentLangIndex = selectedRow
            updateLang()
            updateBook()
        case 1:
            if selectedRow == theSelectUnitsViewModel.currentBookIndex {return}
            theSelectUnitsViewModel.currentBookIndex = selectedRow
            updateBook()
        case 2:
            let m = theSelectUnitsViewModel.currentBook
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
        let m = theSelectUnitsViewModel.currentLang
        langCell.textLabel!.text = m.LANGNAME
    }
    
    func updateBook() {
        let m = theSelectUnitsViewModel.currentBook
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
