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

class WordsSearchViewController: WordsBaseViewController {
    
    var arrWords = [MUnitWord]()

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func searchWordInTableView() {
        searchWord(word: arrWords[tableView.selectedRow].WORD)
    }

    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = MUnitWord()
        item.WORD = newWord
        item.SEQNUM = arrWords.count + 1
        item.NOTE = ""
        arrWords.append(item)
        tableView.reloadData()
        tfNewWord.stringValue = ""
        newWord = ""
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
    }
    
    @IBAction func deleteWord(_ sender: Any) {
    }
    
    @IBAction func refreshTableView(_ sender: Any) {
        arrWords.removeAll()
        tableView.reloadData()
    }

    @IBAction func editWord(_ sender: Any) {
    }
    
    @IBAction func getNote(_ sender: Any) {
    }
}

class WordsSearchWindowController: WordsWindowController {
}
