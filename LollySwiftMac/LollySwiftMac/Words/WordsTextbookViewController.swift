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

class WordsTextbookViewController: WordsViewController {

    var wc2: WordsTextbookWindowController! { return view.window!.windowController as? WordsTextbookWindowController }
    var vm: WordsTextbookViewModel!
    var arrWords: [MTextbookWord] {
        return vm.arrWordsFiltered == nil ? vm.arrWords : vm.arrWordsFiltered!
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
        return arrWords.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        let item = arrWords[row]
        let columnName = tableColumn!.title
        cell.textField?.stringValue = columnName == "PART" ? item.PARTSTR(arrParts: vm.vmSettings.arrParts) : String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = arrWords[row]
        let oldValue = String(describing: item.value(forKey: key))
        var newValue = sender.stringValue
        if key == "WORD" {
            newValue = vmSettings.autoCorrectInput(text: newValue)
        }
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        WordsTextbookViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    override func searchWordInTableView() {
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsTextbookViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsTextbookDetailViewController") as! WordsTextbookDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.mWord = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: Any) {
        let col = tableView.tableColumns.index(where: {$0.title == "NOTE"})!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    @IBAction func copyWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        MacApi.copyText(item.WORD)
    }
    
    @IBAction func googleWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        MacApi.googleString(item.WORD)
    }
    
    @IBAction func openOnlineDict(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        openOnlineDict(word: item.WORD)
    }
    
    @IBAction func filterWord(_ sender: Any) {
        let n = (sender as! NSSegmentedControl).selectedSegment
        if n == 0 {
            vm.arrWordsFiltered = nil
        } else {
            vm.filterWordsForSearchText(wc2.filterText, scope: "Word")
        }
        self.tableView.reloadData()
    }

    override func settingsChanged() {
        super.settingsChanged()
        refreshTableView(self)
    }

    deinit {
    }
}

class WordsTextbookWindowController: WordsWindowController, NSTextFieldDelegate {
    @IBOutlet weak var scFilter: NSSegmentedControl!
    @IBOutlet weak var tfFilterText: NSTextField!
    @objc var filterText = ""
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        let searchfield = obj.object as! NSControl
        guard searchfield === tfFilterText else {return}
        let dict = (obj as NSNotification).userInfo!
        let reason = dict["NSTextMovement"] as! NSNumber
        let code = Int(reason.int32Value)
        guard code == NSReturnTextMovement else {return}
        if scFilter.selectedSegment == 0 {
            scFilter.selectedSegment = 1
        }
        (contentViewController as! WordsTextbookViewController).filterWord(scFilter)
    }
}
