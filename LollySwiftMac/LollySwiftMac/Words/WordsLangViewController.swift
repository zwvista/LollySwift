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

class WordsLangViewController: WordsBaseViewController, NSMenuItemValidation {

    var wc2: WordsLangWindowController! { return view.window!.windowController as? WordsLangWindowController }
    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] {
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
        cell.textField?.stringValue = String(describing: item.value(forKey: columnName) ?? "")
        return cell;
    }
    
    override func levelForRow(row: Int) -> Int {
        return arrWords[row].LEVEL
    }
    
    override func levelChanged(by delta: Int, row: Int) -> Observable<()> {
        let item = arrWords[row]
        item.LEVEL += delta
        return MWordFami.update(wordid: item.ID, level: item.LEVEL)
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
        WordsLangViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    override func searchWordInTableView() {
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }
    
    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = vm.newLangWord()
        item.WORD = vm.vmSettings.autoCorrectInput(text: newWord)
        WordsLangViewModel.create(item: item).subscribe(onNext: {
            item.ID = $0
            self.vm.arrWords.append(item)
            self.tableView.reloadData()
            self.sfNewWord.stringValue = ""
            self.newWord = ""
        }).disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangWord()
        detailVC.complete = { self.tableView.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag) {
            self.tableView.reloadData()
        }
    }

    @IBAction func editWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: Any) {
        let col = tableView.tableColumns.index(where: {$0.title == "NOTE"})!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.getNote(_:)) {
            return vmSettings.hasNote
        }
        return true
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
        refreshTableView(self)
        super.settingsChanged()
    }
}

class WordsLangWindowController: WordsBaseWindowController, NSTextFieldDelegate {
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
        (contentViewController as! WordsLangViewController).filterWord(scFilter)
    }
}

