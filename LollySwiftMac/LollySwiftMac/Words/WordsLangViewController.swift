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

    var vm: WordsLangViewModel!
    override var vmSettings: SettingsViewModel! {
        return vm.vmSettings
    }
    var arrWords: [MLangWord] {
        return vm.arrWordsFiltered ?? vm.arrWords
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, disposeBag: disposeBag, needCopy: true) {
            self.refreshTableView(self)
        }
        super.settingsChanged()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //MARK: tableView

    override func itemForRow(row: Int) -> (MWordProtocol & NSObject)? {
        return arrWords[row]
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return arrWords.count
    }
    
    override func levelChanged(row: Int) -> Observable<Int> {
        let item = arrWords[row]
        return MWordFami.update(wordid: item.ID, level: item.LEVEL).map { 1 }
    }

    override func endEditing(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.update(item: item).subscribe {
            self.tableView.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }.disposed(by: disposeBag)
    }
    
    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = vm.newLangWord()
        item.WORD = vm.vmSettings.autoCorrectInput(text: newWord)
        WordsLangViewModel.create(item: item).subscribe(onNext: {
            item.ID = $0
            self.vm.arrWords.append(item)
            self.tableView.reloadData()
            self.tfNewWord.stringValue = ""
            self.newWord = ""
        }).disposed(by: disposeBag)
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        detailVC.item = vm.newLangWord()
        detailVC.complete = { self.tableView.reloadData(); self.addWord(self) }
        self.presentAsSheet(detailVC)
    }

    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.delete(item: item).subscribe {
            self.refreshTableView(self)
        }.disposed(by: disposeBag)
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        tableView.reloadData()
        updateStatusText()
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let detailVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        detailVC.vm = vm
        let i = tableView.selectedRow
        detailVC.item = MLangWord()
        detailVC.item.copy(from: arrWords[i])
        detailVC.complete = {
            self.arrWords[i].copy(from: detailVC.item)
            self.tableView.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tableView.tableColumns.count))
        }
        self.presentAsModalWindow(detailVC)
    }
    
    @IBAction func getNote(_ sender: AnyObject) {
        let col = tableView.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tableView.selectedRow).subscribe {
            self.tableView.reloadData(forRowIndexes: [self.tableView.selectedRow], columnIndexes: [col])
        }.disposed(by: disposeBag)
    }
    
    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(self.getNote(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        let n = scTextFilter.selectedSegment
        if n == 0 {
            vm.arrWordsFiltered = nil
        } else {
            vm.applyFilters(textFilter: textFilter, scope: n == 1 ? "Word" : "Note", levelge0only: levelge0only)
        }
        self.tableView.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tableView.numberOfRows) Words in \(vmSettings.LANGINFO)"
    }
}

class WordsLangWindowController: WordsBaseWindowController {
}

