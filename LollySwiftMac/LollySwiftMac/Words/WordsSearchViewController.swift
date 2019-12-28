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
    
    var vm: WordsSearchViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func settingsChanged() {
        vm = WordsSearchViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.refreshTableView(self)
        }
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return vm.arrWords.count
    }
    
    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return vm.arrWords[row]
    }

    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = MUnitWord()
        item.WORD = newWord
        item.SEQNUM = vm.arrWords.count + 1
        item.NOTE = ""
        vm.arrWords.append(item)
        tvWords.reloadData()
        tfNewWord.stringValue = ""
        newWord = ""
        tvWords.selectRowIndexes(IndexSet(integer: vm.arrWords.count - 1), byExtendingSelection: false)
        responder = tfNewWord
    }
    
    func addNewWord(word: String) {
        newWord = word
        addNewWord()
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.arrWords.removeAll()
        tvWords.reloadData()
    }

    @IBAction func editWord(_ sender: AnyObject) {
    }
    
    @IBAction func getNote(_ sender: AnyObject) {
    }
    
    override func needRegainFocus() -> Bool {
        return false
    }
}

class WordsSearchWindowController: WordsBaseWindowController {
}
