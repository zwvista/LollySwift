//
//  ViewController.swift
//  LollySwiftMac
//
//  Created by 趙偉 on 2016/07/10.
//  Copyright © 2016年 趙偉. All rights reserved.
//

import Cocoa
import WebKit
import Combine

class WordsSearchViewController: WordsBaseViewController {

    var vm: WordsSearchViewModel!
    override var vmWords: WordsBaseViewModel { vm }
    override var vmSettings: SettingsViewModel! { vm.vmSettings }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsSearchViewModel(settings: AppDelegate.theSettingsViewModel)
        tvWords.reloadData()
        super.settingsChanged()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        vm.arrWords.count
    }

    override func wordItemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        vm.arrWords[row]
    }

    override func addNewWord() {
        guard !vm.newWord.isEmpty else {return}
        vm.addNewWord()
        tvWords.reloadData()
        tvWords.selectRowIndexes(IndexSet(integer: vm.arrWords.count - 1), byExtendingSelection: false)
        responder = tfNewWord
    }

    func addNewWord(word: String) {
        vm.newWord = word
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

    override func getPhrases() async {
    }
}

class WordsSearchWindowController: WordsBaseWindowController {
}
