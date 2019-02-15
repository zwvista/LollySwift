//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import RxSwift

class PhrasesTextbookViewController: PhrasesViewController {
    
    var vm: PhrasesTextbookViewModel!
    var arrPhrases: [MTextbookPhrase] {
        return vm.arrPhrases
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshTableView(self)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrPhrases.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrPhrases[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = columnName == "PART" ? item.PARTSTR(arrParts: vm.vmSettings.arrParts) : String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = arrPhrases[row]
        let oldValue = String(describing: item.value(forKey: key)!)
        var newValue = sender.stringValue
        if key == "PHRASE" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        PhrasesTextbookViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    @IBAction func deletePhrase(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = PhrasesTextbookViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editPhrase(_ sender: Any) {
//        let detailVC = self.storyboard!.instantiateController(withIdentifier: "PhrasesUnitDetailViewController") as! PhrasesUnitDetailViewController
//        detailVC.vm = vm
//        let i = tableView.selectedRow
//        detailVC.mPhrase = vm.arrPhrases[i]
//        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
//        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyPhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.copyText(item.PHRASE)
    }
    
    @IBAction func googlePhrase(_ sender: Any) {
        let item = vm.arrPhrases[tableView.selectedRow]
        MacApi.googleString(item.PHRASE)
    }
    
    override func settingsChanged() {
        refreshTableView(self)
    }
}

class PhrasesTextbookWindowController: NSWindowController {
}
