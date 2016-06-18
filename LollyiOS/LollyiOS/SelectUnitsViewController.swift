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
    
    var selectedSection = 0
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
        selectedSection = indexPath.section
        switch selectedSection {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select A Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [theSelectUnitsViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select A Book", delegate: self, showCancelButton: true, origin: bookCell, initialSelections: [theSelectUnitsViewModel.currentBookIndex])
        default:
            break
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch selectedSection {
        case 0:
            return theSelectUnitsViewModel.arrLanguages.count
        case 1:
            return theSelectUnitsViewModel.arrBooks.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedSection {
        case 0:
            let m = theSelectUnitsViewModel.arrLanguages[row]
            return m.LANGNAME
        case 1:
            let m = theSelectUnitsViewModel.arrBooks[row]
            return m.BOOKNAME
        default:
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
    
    func actionSheetPickerDidSucceed(actionSheetPicker: AbstractActionSheetPicker!, origin: AnyObject!) {
        switch selectedSection {
        case 0:
            let oldRow = theSelectUnitsViewModel.currentLangIndex
            if selectedRow == oldRow {return}
            theSelectUnitsViewModel.currentLangIndex = selectedRow
            updateLang()
            updateBook()
        case 1:
            let oldRow = theSelectUnitsViewModel.currentBookIndex
            if selectedRow == oldRow {return}
            theSelectUnitsViewModel.currentBookIndex = selectedRow
            updateBook()
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
    }

    @IBAction func swUnitToValueChanged(sender: AnyObject) {
        tfUnitTo.enabled = swUnitTo.on
    }
}
