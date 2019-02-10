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

class WordsLangViewController: WordsViewController {

    var vm: WordsLangViewModel!
    var arrWords: [MLangWord] {
        return vm.arrWords
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
    
    @IBAction func endEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let key = tableView.tableColumns[col].title
        let item = arrWords[row]
        let oldValue = String(describing: item.value(forKey: key))
        let newValue = sender.stringValue
        guard oldValue != newValue else {return}
        item.setValue(newValue, forKey: key)
        WordsLangViewModel.update(item: item).subscribe().disposed(by: disposeBag)
    }
    
    override func searchWordInTableView() {
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }
    
    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let mWord = vm.newLangWord()
        mWord.WORD = newWord
        WordsLangViewModel.create(item: mWord).subscribe(onNext: {
            mWord.ID = $0
            self.vm.arrWords.append(mWord)
            self.tableView.reloadData()
            self.tfNewWord.stringValue = ""
            self.newWord = ""
        }).disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: Any) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        detailVC.mWord = vm.newLangWord()
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
        detailVC.mWord = vm.arrWords[i]
        detailVC.complete = { self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count)) }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func copyWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        MacApi.copyText(item.WORD)
    }
    
    @IBAction func googleWord(_ sender: Any) {
        let item = vm.arrWords[tableView.selectedRow]
        MacApi.googleString(item.WORD)
    }

    override func settingsChanged() {
        super.settingsChanged()
        refreshTableView(self)
    }

    deinit {
    }
}

class WordsLangWindowController: WordsWindowController {
}

