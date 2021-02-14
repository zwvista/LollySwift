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
    
    @objc var vm: WordsSearchViewModel!
    override var vmSettings: SettingsViewModel! { vm.vmSettings }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsSearchViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.refreshTableView(self)
        }
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrWords.count
    }
    
    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        vm.arrWords[row]
    }

    override func addNewWord() {
        guard !vm.newWord.value.isEmpty else {return}
        let item = MUnitWord()
        item.WORD = vm.newWord.value
        item.SEQNUM = vm.arrWords.count + 1
        item.NOTE = ""
        vm.arrWords.append(item)
        tvWords.reloadData()
        tfNewWord.stringValue = ""
        vm.newWord.accept("")
        tvWords.selectRowIndexes(IndexSet(integer: vm.arrWords.count - 1), byExtendingSelection: false)
        responder = tfNewWord
    }
    
    func addNewWord(word: String) {
        vm.newWord.accept(word)
        addNewWord()
    }
    
    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.arrWords.removeAll()
        tvWords.reloadData()
    }

    @IBAction func editWord(_ sender: AnyObject) {
    }
    
    override func confirmDelete() -> Bool {
        false
    }

    override func deleteWord(row: Int) {
        vm.arrWords.remove(at: row)
        tvWords.reloadData()
    }

    @IBAction func getNote(_ sender: AnyObject) {
    }
    
    override func needRegainFocus() -> Bool {
        false
    }
    
    override func getPhrases() {
    }
}

class WordsSearchWindowController: WordsBaseWindowController {
}
