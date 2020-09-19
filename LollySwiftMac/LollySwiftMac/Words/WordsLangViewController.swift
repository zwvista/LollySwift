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
import NSObject_Rx

class WordsLangViewController: WordsBaseViewController, NSMenuItemValidation {

    var vm: WordsLangViewModel!
    override var vmSettings: SettingsViewModel! { vm.vmSettings }
    var arrWords: [MLangWord] { vm.arrWordsFiltered ?? vm.arrWords }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func settingsChanged() {
        vm = WordsLangViewModel(settings: AppDelegate.theSettingsViewModel, needCopy: true) {
            self.doRefresh()
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
        arrWords[row]
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        arrWords.count
    }

    override func endEditing(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.update(item: item).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [row], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }) ~ rx.disposeBag
    }
    
    override func addNewWord() {
        guard !newWord.isEmpty else {return}
        let item = vm.newLangWord()
        item.WORD = vm.vmSettings.autoCorrectInput(text: newWord)
        WordsLangViewModel.create(item: item).subscribe(onNext: {
            self.vm.arrWords.append(item)
            self.tvWords.reloadData()
            self.tfNewWord.stringValue = ""
            self.newWord = ""
        }) ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/24219441/how-to-use-nstoolbar-in-xcode-6-and-storyboard
    @IBAction func addWord(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        editVC.vm = vm
        editVC.item = vm.newLangWord()
        editVC.complete = { self.tvWords.reloadData(); self.addWord(self) }
        self.presentAsSheet(editVC)
    }

    override func deleteWord(row: Int) {
        let item = arrWords[row]
        WordsLangViewModel.delete(item: item).subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }

    @IBAction func refreshTableView(_ sender: AnyObject) {
        vm.reload().subscribe(onNext: {
            self.doRefresh()
        }) ~ rx.disposeBag
    }

    @IBAction func editWord(_ sender: AnyObject) {
        let editVC = self.storyboard!.instantiateController(withIdentifier: "WordsLangDetailViewController") as! WordsLangDetailViewController
        editVC.vm = vm
        let i = tvWords.selectedRow
        editVC.item = arrWords[i]
        editVC.complete = {
            self.tvWords.reloadData(forRowIndexes: [i], columnIndexes: IndexSet(0..<self.tvWords.tableColumns.count))
        }
        self.presentAsModalWindow(editVC)
    }
    
    @IBAction func getNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.getNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }
    
    @IBAction func clearNote(_ sender: AnyObject) {
        let col = tvWords.tableColumns.firstIndex { $0.title == "NOTE" }!
        vm.clearNote(index: tvWords.selectedRow).subscribe(onNext: {
            self.tvWords.reloadData(forRowIndexes: [self.tvWords.selectedRow], columnIndexes: [col])
        }) ~ rx.disposeBag
    }

    // https://stackoverflow.com/questions/9368654/cannot-seem-to-setenabledno-on-nsmenuitem
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(getNote(_:)) {
            return vmSettings.hasDictNote
        }
        return true
    }

    @IBAction func filterWord(_ sender: AnyObject) {
        vm.applyFilters(textFilter: textFilter, scope: scTextFilter.selectedSegment == 0 ? "Word" : "Note")
        self.tvWords.reloadData()
    }

    override func updateStatusText() {
        tfStatusText.stringValue = "\(tvWords.numberOfRows) Words in \(vmSettings.LANGINFO)"
    }

    @IBAction func selectPhrases(_ sender: AnyObject) {
        guard selectedWordID != 0 else {return}
        let detailVC = NSStoryboard(name: "Phrases", bundle: nil).instantiateController(withIdentifier: "PhrasesSelectUnitViewController") as! PhrasesSelectUnitViewController
        detailVC.textFilter = selectedWord
        detailVC.wordid = selectedWordID
        detailVC.complete = {
            self.searchPhrases()
        }
        self.presentAsModalWindow(detailVC)
    }
}

class WordsLangWindowController: WordsBaseWindowController {
}

