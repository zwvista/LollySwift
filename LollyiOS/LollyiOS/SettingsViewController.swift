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
    
    var selectedSection = 0
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLang()
        updateDict()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedSection = indexPath.section
        switch selectedSection {
        case 0:
            ActionSheetCustomPicker.showPickerWithTitle("Select A Language", delegate: self, showCancelButton: true, origin: langCell, initialSelections: [theWordsOnlineViewModel.currentLangIndex])
        case 1:
            ActionSheetCustomPicker.showPickerWithTitle("Select A Dictionary", delegate: self, showCancelButton: true, origin: dictCell, initialSelections: [theWordsOnlineViewModel.currentDictIndex])
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
            return theWordsOnlineViewModel.arrLanguages.count
        case 1:
            return theWordsOnlineViewModel.arrDictAll.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch selectedSection {
        case 0:
            let m = theWordsOnlineViewModel.arrLanguages[row]
            return m.LANGNAME
        case 1:
            let m = theWordsOnlineViewModel.arrDictAll[row]
            return m.DICTNAME
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
            let oldRow = theWordsOnlineViewModel.currentLangIndex
            if selectedRow == oldRow {return}
            theWordsOnlineViewModel.currentLangIndex = selectedRow
            updateLang()
            updateDict()
        case 1:
            let oldRow = theWordsOnlineViewModel.currentDictIndex
            if selectedRow == oldRow {return}
            theWordsOnlineViewModel.currentDictIndex = selectedRow
            updateDict()
        default:
            break
        }
    }
    
    func updateLang() {
        let m = theWordsOnlineViewModel.arrLanguages[theWordsOnlineViewModel.currentLangIndex]
        langCell.textLabel!.text = m.LANGNAME
    }
    
    func updateDict() {
        let m = theWordsOnlineViewModel.arrDictAll[theWordsOnlineViewModel.currentDictIndex]
        dictCell.textLabel!.text = m.DICTNAME
        dictCell.detailTextLabel!.text = m.URL
    }
    
}
